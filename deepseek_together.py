import os
import json
import re
import demjson3
from openai import OpenAI
from dotenv import load_dotenv

# Charger la clé API
load_dotenv()
api_key = os.getenv("TOGETHER_API_KEY")
if not api_key:
    raise ValueError("❌ Clé API Together manquante dans .env")

# Initialisation client Together.ai
client = OpenAI(api_key=api_key, base_url="https://api.together.xyz/v1")

# Fichiers
feature_path = "TC01.feature"
output_json_path = "validation_result.json"
corrected_feature_path = "corrected.feature"

# Lecture du fichier feature
if not os.path.exists(feature_path):
    raise FileNotFoundError(f"❌ Fichier introuvable : {feature_path}")

with open(feature_path, "r", encoding="utf-8") as f:
    feature_code = f.read()

print("⏳ Envoi à Mistral-7B-Instruct via Together.ai...")

# Prompt système
prompt_system = (
    "You are a Gherkin validation and correction expert.\n"
    "You will receive a `.feature` file written in Gherkin syntax.\n"
    "Return a JSON object ONLY, with the following fields:\n"
    "{\n"
    "  \"is_valid\": true or false,\n"
    "  \"good_practices\": [...],\n"
    "  \"errors\": [...],\n"
    "  \"corrected_feature\": \"full corrected feature\"\n"
    "}\n"
    "NEVER output any explanation. NEVER wrap anything in markdown. JSON only."
)

# Appel API avec max_tokens étendu
response = client.chat.completions.create(
    model="mistralai/Mistral-7B-Instruct-v0.3",
    messages=[
        {"role": "system", "content": prompt_system},
        {"role": "user", "content": f"Voici le fichier à valider :\n\n{feature_code}"}
    ],
    temperature=0.3,
    max_tokens=2048  # ⬅️ important pour éviter les coupures
)

# Récupération brute de la réponse
result_text = response.choices[0].message.content.strip()

# Sauvegarde brute
with open("raw_model_output.txt", "w", encoding="utf-8") as f:
    f.write(result_text)

# Si le JSON est tronqué, on le signale
if not result_text.endswith("}"):
    print("❌ Réponse du modèle tronquée (JSON incomplet).")
    exit(1)

# Fonction d'extraction JSON robuste
def extract_json_fields(text):
    try:
        # Supprimer tout avant la 1re accolade
        start = text.find('{')
        if start == -1:
            raise ValueError("Aucune accolade ouvrante trouvée.")
        text = text[start:]

        # Extraire bloc JSON équilibré
        depth = 0
        end = None
        for i, char in enumerate(text):
            if char == '{':
                depth += 1
            elif char == '}':
                depth -= 1
                if depth == 0:
                    end = i + 1
                    break
        if end is None:
            raise ValueError("Blocs JSON non équilibrés.")

        json_text = text[:end]

        # Nettoyage de corrected_feature
        match = re.search(r'"corrected_feature"\s*:\s*"(.*?)"\s*(,|\})', json_text, re.DOTALL)
        if match:
            corrected_raw = match.group(1)

            # Échappement manuel
            corrected_clean = corrected_raw.replace('\\', '\\\\')\
                                           .replace('\n', '\\n')\
                                           .replace('\r', '\\r')\
                                           .replace('\t', '\\t')\
                                           .replace('"', '\\"')

            json_text = json_text[:match.start(1)] + corrected_clean + json_text[match.end(1):]

        # Parsing final
        return demjson3.decode(json_text)

    except Exception as e:
        raise ValueError(f"❌ Erreur d'extraction JSON : {e}\n💡 Voir raw_model_output.txt")

# Extraction
result_json = extract_json_fields(result_text)

# Sauvegarde JSON
with open(output_json_path, "w", encoding="utf-8") as f:
    json.dump(result_json, f, indent=4, ensure_ascii=False)

# Sauvegarde feature corrigé
with open(corrected_feature_path, "w", encoding="utf-8") as f:
    f.write(result_json["corrected_feature"])

# Affichage
if result_json.get("is_valid"):
    print("\033[92m✅ Le fichier Gherkin est VALIDE.\033[0m")
else:
    print("\033[91m❌ Le fichier est INVALIDE. Voir les erreurs dans le JSON.\033[0m")

print(f"📄 JSON sauvegardé dans : {output_json_path}")
print(f"📝 Feature corrigé : {corrected_feature_path}")
