import os
import json
import re
from openai import OpenAI
from dotenv import load_dotenv

# Charger la clé API depuis .env
load_dotenv()
api_key = os.getenv("TOGETHER_API_KEY")

if not api_key:
    raise ValueError("❌ Clé API Together manquante dans .env")

# Initialisation du client Together.ai
client = OpenAI(
    api_key=api_key,
    base_url="https://api.together.xyz/v1"
)

# Modèle utilisé
model = "mistralai/Mistral-7B-Instruct-v0.3"

# Fichiers
feature_path = "TC01.feature"
output_json_path = "validation_result1.json"

# Lire le fichier .feature
if not os.path.exists(feature_path):
    raise FileNotFoundError(f"❌ Fichier introuvable : {feature_path}")

with open(feature_path, "r", encoding="utf-8") as f:
    feature_code = f.read()

print("⏳ Envoi à Mistral-7B-Instruct via Together.ai...")

# Prompt structuré pour validation + correction
response = client.chat.completions.create(
    model=model,
    messages=[
        {
            "role": "system",
            "content": (
                "Tu es un expert en validation de fichiers Gherkin.\n"
                "Analyse le fichier et retourne uniquement un JSON de structure suivante :\n\n"
                "{\n"
                "  \"is_valid\": true ou false,\n"
                "  \"good_practices\": [liste de bonnes pratiques],\n"
                "  \"errors\": [liste d’erreurs critiques empêchant l'exécution correcte],\n"
                "  \"corrected_feature\": \"texte complet du fichier corrigé\"\n"
                "}\n\n"
                "⚠️ Aucun texte hors JSON, pas d'explications."
            )
        },
        {
            "role": "user",
            "content": f"Voici le fichier Gherkin à corriger et valider :\n\n{feature_code}"
        }
    ],
    temperature=0.3
)

# Nettoyage et extraction JSON
result_text = response.choices[0].message.content.strip()

try:
    json_match = re.search(r"\{[\s\S]*\}", result_text)
    if not json_match:
        raise ValueError("❌ Aucun bloc JSON valide trouvé dans la réponse.")
    result_json = json.loads(json_match.group(0))
except Exception as e:
    with open("raw_model_output.txt", "w", encoding="utf-8") as f:
        f.write(result_text)
    raise ValueError(f"❌ Réponse JSON invalide : {e}\n💡 Voir raw_model_output.txt")

# Construire le fichier final
final_output = {
    "input_file": feature_path,
    "is_valid": result_json.get("is_valid", False),
    "good_practices": result_json.get("good_practices", []),
    "errors": result_json.get("errors", []),
    "corrected_feature": result_json.get("corrected_feature", "")
}

# Sauvegarde dans un fichier JSON
with open(output_json_path, "w", encoding="utf-8") as f:
    json.dump(final_output, f, indent=4, ensure_ascii=False)

# Résultat console
if final_output["is_valid"]:
    print("\033[92m✅ Le fichier Gherkin est VALIDE.\033[0m")
else:
    print("\033[91m❌ Le fichier Gherkin est INVALIDE. Voir les erreurs et la correction dans le JSON.\033[0m")

print(f"📄 Résultat sauvegardé dans : {output_json_path}")
