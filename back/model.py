import os
import re
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()
api_key = os.getenv("TOGETHER_API_KEY")
if not api_key:
    raise ValueError("❌ Clé API Together manquante dans .env")

client = OpenAI(api_key=api_key, base_url="https://api.together.xyz/v1")

def lancer_validation(feature_path):
    if not os.path.exists(feature_path):
        raise FileNotFoundError("❌ Fichier introuvable")

    with open(feature_path, "r", encoding="utf-8") as f:
        feature_code = f.read()

    response = client.chat.completions.create(
        model="meta-llama/Llama-3.3-70B-Instruct-Turbo-Free",
        messages=[
            {
              "role": "system",
            "content": (
                "Tu es un expert Gherkin. Corrige uniquement la syntaxe sans toucher à la logique. "
                "Retourne un JSON STRICTEMENT au format :\n"
                "{\n"
                "  \"is_valid\": true ou false,\n"
                "  \"good_practices\": [...],\n"
                "  \"errors\": [...],\n"
                "  \"corrected_feature\": \"...\"\n"
                "}\n"
                "Pas de texte hors JSON."
            )
            },
            {
                "role": "user",
                "content": feature_code
            }
        ],
        temperature=0.3
    )

    result_text = response.choices[0].message.content.strip()
    match = re.search(r'"corrected_feature"\s*:\s*"(.*)', result_text, re.DOTALL)
    if not match:
        raise ValueError("❌ Impossible de localiser corrected_feature")

    raw = match.group(1)
    if raw.endswith('"}'):
        raw = raw[:-2]
    elif raw.endswith('"'):
        raw = raw[:-1]

    corrected = raw.encode("utf-8").decode("unicode_escape")

    filename = os.path.basename(feature_path)
    corrected_path = os.path.join("corrected", f"corrected_{filename}")
    with open(corrected_path, "w", encoding="utf-8") as f:
        f.write(corrected)

    return corrected_path
