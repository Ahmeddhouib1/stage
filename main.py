
import os
import json
import zipfile
import joblib
import re

# === Chemins
zip_path = "msr_dataset.zip"
extract_dir = "msr_dataset"

# === Chargement du modèle
clf = joblib.load("gherkin_classifier.pkl")
vectorizer = joblib.load("gherkin_vectorizer.pkl")

# === Labels obligatoires et optionnels
required_labels = {
    "Scenario",
    "Precondition",
    "Send Amount",
    "Card Swipe",
    "Data Parsing",
    "Confirmation"
}

optional_labels = {"CVM Process", "Transaction Completion"}


# === Regrouper blocs
def group_blocks(lines):
    blocks = []
    current = []
    for line in lines:
        if line.startswith(("Given", "When", "Then", "And", "But")) or "Axium" in line or "Element" in line:
            if current:
                blocks.append("\n".join(current))
                current = []
        current.append(line)
    if current:
        blocks.append("\n".join(current))
    return blocks

# === Logique métier : corriger ou ajouter label
def override_logic(block_text, predicted_label):
    block_lower = block_text.lower()

    if "scenario" in block_lower:
        return "Scenario"
    if "pin entry" in block_lower or "pinpad enter pin" in block_lower:
        return "CVM Process"
    if "transaction complete" in block_lower and "title" in block_lower:
        return "Transaction Completion"
    if "13.x" in block_lower:
        return "Send Amount"
    if "00.x" in block_lower:
        return "Precondition"
    if "23.x" in block_lower:
        return "Card Swipe"
    if "24.x" in block_lower:
        return "Confirmation"
    if "29.x" in block_lower:
        return "Data Parsing"
    return predicted_label if predicted_label != "Scenario" else "Unknown"


# === Traitement d’un fichier .feature
def process_feature_file(filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        lines = [line.strip() for line in f if line.strip()]

    grouped = group_blocks(lines)
    X = vectorizer.transform(grouped)
    preds = clf.predict(X)
    corrected = [override_logic(b, l) for b, l in zip(grouped, preds)]

    scenario = next((line.split(":", 1)[-1].strip() for line in lines if line.lower().startswith("scenario")), "")

    found = set(l for l in corrected if l != "Unknown")
    missing_required = sorted(list(required_labels - found))
    missing_optional = sorted(list(optional_labels - found))
    steps_found = sorted(list(found - {"Scenario"}))

    return {
        "file": os.path.basename(filepath),
        "scenario": scenario,
        "steps_found": steps_found,
        "missing_required_steps": missing_required,
        "missing_optional_steps": missing_optional,
        "valid": required_labels.issubset(found)
    }
def is_order_valid(labels_sequence, required_labels):
    # Ne garder que les labels obligatoires dans l’ordre apparu
    filtered = [label for label in labels_sequence if label in required_labels]
    expected = list(required_labels)

    # Vérifier si filtered est dans le même ordre que expected
    expected_idx = 0
    for label in filtered:
        if label == expected[expected_idx]:
            expected_idx += 1
        else:
            return False
        if expected_idx == len(expected):
            break
    return expected_idx == len(expected)

# === Extraction des fichiers
if not os.path.exists(extract_dir):
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall(extract_dir)

# === Traitement global
results = []
for root, _, files in os.walk(extract_dir):
    for file in files:
        if file.endswith(".feature"):
            result = process_feature_file(os.path.join(root, file))
            results.append(result)

summary = {
    "total_files": len(results),
    "valid_files": sum(r["valid"] for r in results),
    "invalid_files": sum(not r["valid"] for r in results),
    "invalid_details": [r for r in results if not r["valid"]]
}

with open("validation_summary.json", "w", encoding="utf-8") as f:
    json.dump(summary, f, indent=2, ensure_ascii=False)

print("✅ Résumé sauvegardé dans validation_summary.json")
