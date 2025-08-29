import os
import re
import json
import time
from json import JSONDecodeError
from dotenv import load_dotenv
from openai import OpenAI, APIError, RateLimitError

load_dotenv()

# ======== Config & client ========
api_key = os.getenv("TOGETHER_API_KEY")
if not api_key:
    raise ValueError("❌ TOGETHER_API_KEY manquante dans .env")

# Primary model (env override allowed)
PRIMARY_MODEL = os.getenv(
    "TOGETHER_MODEL",
    "meta-llama/Llama-3.3-70B-Instruct-Turbo-Free"
)

# Optional comma-separated fallbacks
# e.g.: TOGETHER_FALLBACK_MODELS="Qwen/Qwen2.5-32B-Instruct,meta-llama/Llama-3.1-70B-Instruct"
FALLBACK_MODELS = [
    m.strip() for m in os.getenv("TOGETHER_FALLBACK_MODELS", "").split(",") if m.strip()
]

client = OpenAI(api_key=api_key, base_url="https://api.together.xyz/v1")

# ======== Local rate gate (helps with free-model 0.6 qpm) ========
# If using the free primary model, we avoid firing more than once per ~100s.
_RATE_INTERVAL_SEC = int(os.getenv("LOCAL_RATE_INTERVAL_SEC", "100"))
_last_primary_ts = 0.0


class ModelRateLimit(Exception):
    """Raised when we intentionally surface a 429 to the caller (local gate or persistent provider 429)."""
    pass


# -------------------- Utilities --------------------
def _strip_code_fences(text: str) -> str:
    m = re.search(r"```(?:json)?\s*(\{.*?\})\s*```", text, flags=re.DOTALL | re.IGNORECASE)
    if m:
        return m.group(1).strip()
    return text


def _extract_balanced_json(text: str) -> str:
    text = _strip_code_fences(text)
    start = text.find("{")
    if start == -1:
        raise ValueError("❌ Le modèle n’a pas renvoyé de JSON (aucune '{').")

    depth = 0
    end = -1
    in_str = False
    esc = False

    for i in range(start, len(text)):
        ch = text[i]
        if in_str:
            if esc:
                esc = False
            elif ch == "\\":
                esc = True
            elif ch == '"':
                in_str = False
            continue
        else:
            if ch == '"':
                in_str = True
                continue

        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                end = i
                break

    if end == -1:
        raise ValueError("❌ JSON non équilibré (braces non appariées).")
    return text[start:end + 1]


def _json_loads_lenient(s: str) -> dict:
    try:
        return json.loads(s)
    except JSONDecodeError:
        # remove trailing commas
        cleaned = re.sub(r',(\s*[}\]])', r'\1', s)
        return json.loads(cleaned)


def _fallback_extract_fields(raw: str) -> dict:
    # corrected_feature
    cf = None
    m = re.search(r'"corrected_feature"\s*:\s*"(.+?)"\s*(?:,|\})', raw, flags=re.DOTALL)
    if m:
        cf = m.group(1)
        # unescape common sequences
        cf = cf.encode("utf-8").decode("unicode_escape")

    def _extract_array(key: str):
        mm = re.search(rf'"{key}"\s*:\s*(\[(?:.|\n)*?\])', raw, flags=re.DOTALL)
        if not mm:
            return []
        chunk = mm.group(1).strip()
        try:
            return json.loads(chunk)
        except Exception:
            chunk2 = re.sub(r"'", r'"', chunk)
            chunk2 = re.sub(r',(\s*[\]\}])', r'\1', chunk2)
            try:
                return json.loads(chunk2)
            except Exception:
                return re.findall(r'"(.*?)"', chunk)

    errors = _extract_array("errors")
    good_practices = _extract_array("good_practices")
    return {"corrected_feature": cf, "errors": errors, "good_practices": good_practices}


def _save_raw_output(text: str):
    os.makedirs("corrected", exist_ok=True)
    with open(os.path.join("corrected", "last_raw_model_output.txt"), "w", encoding="utf-8") as f:
        f.write(text)


# -------------------- LLM calls (retry + fallback + local gate) --------------------
def _chat_once(feature_code: str, model_name: str, use_response_format: bool = True) -> str:
    kwargs = dict(
        model=model_name,
        messages=[
            {
                "role": "system",
                "content": (
                    "Tu es un expert Gherkin. Corrige uniquement la syntaxe sans toucher à la logique. "
                    "Réponds en JSON STRICT et UNIQUEMENT JSON, sans backticks et sans texte hors JSON. "
                    "Schéma attendu : "
                    "{"
                    "\"is_valid\": (true/false), "
                    "\"good_practices\": [string], "
                    "\"errors\": [string], "
                    "\"corrected_feature\": string"
                    "}"
                )
            },
            {"role": "user", "content": feature_code}
        ],
        temperature=0.3,
    )
    if use_response_format:
        kwargs["response_format"] = {"type": "json_object"}

    resp = client.chat.completions.create(**kwargs)
    return (resp.choices[0].message.content or "").strip()


def _local_rate_gate_or_none(model_name: str):
    """
    If using the free primary model, enforce ~1 call / 100s.
    Raise ModelRateLimit if too soon. This avoids instant provider 429s.
    """
    global _last_primary_ts
    if model_name != PRIMARY_MODEL:
        return  # only gate the primary (likely the free one)

    now = time.time()
    if _last_primary_ts and (now - _last_primary_ts) < _RATE_INTERVAL_SEC:
        remaining = int(_RATE_INTERVAL_SEC - (now - _last_primary_ts))
        raise ModelRateLimit(
            f"Rate limit local: attendez ~{remaining}s avant une nouvelle validation (modèle gratuit {PRIMARY_MODEL})."
        )
    # Reserve the slot (optimistic). If the call fails quickly, it's OK — next call will wait again.
    _last_primary_ts = now


def _call_model_with_retries(feature_code: str) -> str:
    """
    Try primary (with local gate) then fallbacks. For each:
      - Try WITH response_format then WITHOUT.
      - Exponential backoff on 429 (100s -> 200s -> 400s).
    On persistent 429s across all candidates, raise ModelRateLimit.
    """
    candidates = [PRIMARY_MODEL] + FALLBACK_MODELS

    # Free-tier tuned backoff
    MAX_ATTEMPTS = 3
    INITIAL_BACKOFF = 100  # seconds (free model is 0.6 qpm)
    BACKOFF_FACTOR = 2.0

    last_err = None
    saw_rate_limits = False

    for model_name in candidates:
        # Apply the local gate only to the primary free model
        try:
            _local_rate_gate_or_none(model_name)
        except ModelRateLimit as e:
            # If we have fallbacks, skip primary and try them.
            if model_name == PRIMARY_MODEL and FALLBACK_MODELS:
                # do not mark saw_rate_limits; this is local gate only
                pass
            else:
                # No fallback: surface 429 to caller
                raise

        # 1) Try WITH response_format
        backoff = INITIAL_BACKOFF
        for attempt in range(1, MAX_ATTEMPTS + 1):
            try:
                return _chat_once(feature_code, model_name, use_response_format=True)
            except RateLimitError as e:
                last_err = e
                saw_rate_limits = True
                time.sleep(backoff)
                backoff = int(backoff * BACKOFF_FACTOR)
            except APIError as e:
                last_err = e
                # Some SDKs wrap 429 as APIError with status_code
                if getattr(e, "status_code", None) == 429:
                    saw_rate_limits = True
                    time.sleep(backoff)
                    backoff = int(backoff * BACKOFF_FACTOR)
                else:
                    break  # other API errors => try without response_format
            except Exception as e:
                last_err = e
                break

        # 2) Try WITHOUT response_format
        backoff = INITIAL_BACKOFF
        for attempt in range(1, MAX_ATTEMPTS + 1):
            try:
                return _chat_once(feature_code, model_name, use_response_format=False)
            except RateLimitError as e:
                last_err = e
                saw_rate_limits = True
                time.sleep(backoff)
                backoff = int(backoff * BACKOFF_FACTOR)
            except APIError as e:
                last_err = e
                if getattr(e, "status_code", None) == 429:
                    saw_rate_limits = True
                    time.sleep(backoff)
                    backoff = int(backoff * BACKOFF_FACTOR)
                else:
                    break
            except Exception as e:
                last_err = e
                break

        # If we got here, this candidate failed; try next candidate

    if saw_rate_limits:
        raise ModelRateLimit(
            "Rate limit du fournisseur atteint sur tous les modèles testés. "
            "Réessayez plus tard, augmentez vos quotas, ou configurez des modèles de fallback."
        )
    raise RuntimeError(f"❌ Appel au modèle impossible: {last_err}")


# -------------------- Public entrypoint --------------------
def lancer_validation(feature_path: str):
    if not os.path.exists(feature_path):
        raise FileNotFoundError("❌ Fichier introuvable")

    with open(feature_path, "r", encoding="utf-8") as f:
        feature_code = f.read()

    # Try LLM (with retries/fallback/gate)
    result_text = _call_model_with_retries(feature_code)

    # Keep raw output for debugging
    _save_raw_output(result_text)

    # Parse JSON (strict first, then tolerant)
    try:
        json_str = _extract_balanced_json(result_text)
        data = _json_loads_lenient(json_str)
        corrected_feature = data.get("corrected_feature")
        errors = data.get("errors", [])
        good_practices = data.get("good_practices", [])
    except Exception:
        fields = _fallback_extract_fields(result_text)
        corrected_feature = fields.get("corrected_feature")
        errors = fields.get("errors", [])
        good_practices = fields.get("good_practices", [])

    if not isinstance(errors, list):
        errors = [str(errors)]
    if not isinstance(good_practices, list):
        good_practices = [str(good_practices)]
    if not corrected_feature or not isinstance(corrected_feature, string_types := str):
        corrected_feature = feature_code

    # Ensure output dir exists
    os.makedirs("corrected", exist_ok=True)

    base = os.path.splitext(os.path.basename(feature_path))[0]
    corrected_path = os.path.join("corrected", f"corrected_{base}.feature")
    report_path = os.path.join("corrected", f"report_{base}.json")

    with open(corrected_path, "w", encoding="utf-8") as f:
        f.write(corrected_feature)

    with open(report_path, "w", encoding="utf-8") as f:
        json.dump({"errors": errors, "good_practices": good_practices}, f, indent=4, ensure_ascii=False)

    return corrected_path, report_path
