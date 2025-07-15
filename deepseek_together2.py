import os
import re
import json
from openai import OpenAI
from dotenv import load_dotenv

# Charger la clé API
load_dotenv()
api_key = os.getenv("TOGETHER_API_KEY")
if not api_key:
    raise ValueError("❌ Clé API Together manquante dans .env")

# Initialisation client Together
client = OpenAI(api_key=api_key, base_url="https://api.together.xyz/v1")

# Fichiers
feature_path = "TC01.feature"
output_json_path = "validation_result_llama.json"
corrected_feature_path = "corrected_llama.feature"
raw_output_path = "raw_llama_output.txt"

# Lecture du fichier .feature
if not os.path.exists(feature_path):
    raise FileNotFoundError("❌ Fichier introuvable : TC01.feature")

with open(feature_path, "r", encoding="utf-8") as f:
    feature_code = f.read()

print("🚀 Envoi à Llama‑3.3‑70B via Together.ai...")

# Envoi au modèle
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

# Sauvegarde brute
result_text = response.choices[0].message.content.strip()
with open(raw_output_path, "w", encoding="utf-8") as f:
    f.write(result_text)

# === Fonctions robustes de parsing ===

def extract_field(name, text):
    match = re.search(rf'"{name}"\s*:\s*(true|false|null|"[^"]*"|\[.*?\])', text, re.DOTALL)
    if not match:
        return None
    val = match.group(1)
    if val == "true":
        return True
    elif val == "false":
        return False
    elif val.startswith('"'):
        return val.strip('"')
    elif val.startswith("["):
        return re.findall(r'"(.*?)"', val)
    return val

def extract_corrected_feature(text):
    match = re.search(r'"corrected_feature"\s*:\s*"(.*)', text, re.DOTALL)
    if not match:
        raise ValueError("❌ Impossible de localiser le début de corrected_feature")

    raw = match.group(1)

    # Nettoyer la fin (enlever guillemets et accolade éventuels)
    if raw.endswith('"}'):
        raw = raw[:-2]
    elif raw.endswith('"'):
        raw = raw[:-1]

    # Dé-échapper les caractères spéciaux
    return raw.encode("utf-8").decode("unicode_escape")

# Extraction
try:
    is_valid = extract_field("is_valid", result_text)
    good_practices = extract_field("good_practices", result_text)
    errors = extract_field("errors", result_text)
    corrected_feature = extract_corrected_feature(result_text)
except Exception as e:
    raise ValueError(f"❌ Échec de l'extraction : {e}\n💡 Voir raw_llama_output.txt")

# Sauvegarde des fichiers
with open(corrected_feature_path, "w", encoding="utf-8") as f:
    f.write(corrected_feature)

final_output = {
    "input_file": feature_path,
    "is_valid": is_valid,
    "good_practices": good_practices,
    "errors": errors,
    "corrected_feature": "(voir corrected.feature)"
}

with open(output_json_path, "w", encoding="utf-8") as f:
    json.dump(final_output, f, indent=4, ensure_ascii=False)

# Résultat console
if is_valid:
    print("\033[92m✅ Le fichier Gherkin est VALIDE.\033[0m")
else:
    print("\033[91m❌ Le fichier Gherkin est INVALIDE. Voir les erreurs.\033[0m")

print(f"📄 Résultat JSON : {output_json_path}")
print(f"📝 Fichier corrigé : {corrected_feature_path}")
