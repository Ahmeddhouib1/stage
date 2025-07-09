import zipfile
import os
import re
import json

# === CONFIGURATION ===
zip_path = r"C:\Users\DHOUIB\Downloads\arc-si_dataset.zip"
extract_dir = r"C:\arc"
output_json = "result_arc_si_validation.json"  # ← Résultat JSON

# === DÉFINITION DES ÉTAPES ATTENDUES POUR ARC-SI ===
expected_steps = [
    ("Precondition", r"Given I use upp-ws transaction endpoint"),
    ("Send Amount", r"When I send upp-ws request.*\"type\":\s*\"sale\""),
    ("Card Swipe", r"When Axium swipe magnetic card"),
    ("Data Parsing", r"Then I should receive upp-ws event subset within 50s"),
    ("Confirmation", r"And I send upp-ws event_ack with status \"ok\""),
    ("CVM Process", r"And when I enter pin"),
    ("Transaction Completion", r"When I send upp-ws event_ack with status \"ok\"")
]

# === EXTRACTION DU ZIP ===
os.makedirs(extract_dir, exist_ok=True)
with zipfile.ZipFile(zip_path, 'r') as zip_ref:
    zip_ref.extractall(extract_dir)

# === ANALYSE DES FICHIERS FEATURE ===
results = []
total_files = 0
valid_files = 0

for root, _, files in os.walk(extract_dir):
    for file in files:
        if file.endswith(".feature"):
            total_files += 1
            filepath = os.path.join(root, file)
            with open(filepath, "r", encoding="utf-8") as f:
                content = f.read()

            found_steps = []
            for label, pattern in expected_steps:
                if re.search(pattern, content, re.IGNORECASE | re.DOTALL):
                    found_steps.append(label)

            missing_steps = [label for label, _ in expected_steps if label not in found_steps]
            expected_labels = [label for label, _ in expected_steps]
            found_order = [label for label in expected_labels if label in found_steps]
            is_order_correct = found_order == sorted(found_order, key=lambda x: expected_labels.index(x))
            is_valid = len(missing_steps) == 0 and is_order_correct
            if is_valid:
                valid_files += 1

            results.append({
                "file": file,
                "found_steps": found_steps,
                "missing_steps": missing_steps,
                "is_order_correct": is_order_correct,
                "is_valid_script": is_valid
            })

# === GÉNÉRATION DU FICHIER JSON ===
final_result = {
    "total_files": total_files,
    "valid_files": valid_files,
    "details": results
}

with open(output_json, "w", encoding="utf-8") as json_file:
    json.dump(final_result, json_file, indent=2, ensure_ascii=False)

print(f"Analyse terminée. Résultat enregistré dans : {output_json}")
