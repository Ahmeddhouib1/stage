import joblib
import json
import re

# === Chargement modèle
clf = joblib.load("gherkin_classifier.pkl")
vectorizer = joblib.load("gherkin_vectorizer.pkl")

# === Labels attendus
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

# === Logique de correction
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


# === Analyse d’un seul fichier
with open("test.feature", "r", encoding="utf-8") as f:
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
valid = required_labels.issubset(found)

output = {
    "scenario": scenario,
    "steps_found": steps_found,
    "missing_required_steps": missing_required,
    "missing_optional_steps": missing_optional,
    "valid": valid
}

with open("output_prediction.json", "w", encoding="utf-8") as f:
    json.dump(output, f, indent=2, ensure_ascii=False)

print("✅ JSON généré : output_prediction.json")
