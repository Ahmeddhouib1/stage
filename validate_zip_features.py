import zipfile
import os
import tempfile
import json
import re

# === Règles de validation ===
REQUIRED_ORDER = [
    "Precondition",
    "Send Amount",
    "Card Swipe",
    "Data Parsing",
    "Confirmation",
    "CVM Process",
    "Transaction Completion"
]

def classify_block(block: str) -> str:
    block_lower = block.lower()
    if "pin entry" in block_lower or "pinpad enter pin" in block_lower or "31.x" in block_lower:
        return "CVM Process"
    if "transaction complete" in block_lower and "title" in block_lower:
        return "Transaction Completion"
    if "13.x" in block_lower:
        return "Send Amount"
    if "00.x" in block_lower or "given " in block_lower or "offline " in block_lower:
        return "Precondition"
    if "23.x" in block_lower:
        return "Card Swipe"
    if "24.x" in block_lower:
        return "Confirmation"
    if "29.x" in block_lower:
        return "Data Parsing"
    return "Unclassified"

def extract_scenario_line(content: str) -> str:
    match = re.search(r'Scenario Outline:\s*(.+)', content)
    return match.group(1).strip() if match else "Not found"

def validate_feature_script_from_content(content: str) -> dict:
    lines = content.splitlines()
    scenario_line = extract_scenario_line(content)
    lines = [line for line in lines if not line.strip().startswith("@")]

    blocks = []
    current_block = ""

    for line in lines:
        if re.match(r'^\s*(Given|When|Then|And)\s+', line):
            if current_block:
                blocks.append(current_block.strip())
            current_block = line
        else:
            current_block += line
    if current_block:
        blocks.append(current_block.strip())

    found_steps = []
    previous_labels = set()
    for block in blocks:
        label = classify_block(block)
        if label != "Unclassified" and label in REQUIRED_ORDER and label not in found_steps:
            found_steps.append(label)
            previous_labels.add(label)

    missing_steps = [step for step in REQUIRED_ORDER if step not in found_steps]
    is_order_correct = found_steps == REQUIRED_ORDER

    return {
        "scenario": scenario_line,
        "found_steps": found_steps,
        "missing_steps": missing_steps,
        "is_order_correct": is_order_correct,
        "is_valid_script": is_order_correct and not missing_steps
    }

def process_zip_file(zip_path: str):
    results = []
    with tempfile.TemporaryDirectory() as tmpdir:
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(tmpdir)

        feature_files = [
            os.path.join(root, file)
            for root, _, files in os.walk(tmpdir)
            for file in files if file.endswith(".feature")
        ]

        for file_path in feature_files:
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()
                result = validate_feature_script_from_content(content)
                result["file"] = os.path.basename(file_path)
                results.append(result)

    # Résumé global
    total = len(results)
    valid = sum(1 for r in results if r["is_valid_script"])
    print(f"\n📦 Total fichiers .feature : {total}")
    print(f"✅ Scripts valides          : {valid}")
    print(f"❌ Scripts invalides        : {total - valid}\n")

    for r in results:
        status = "✅ VALID" if r["is_valid_script"] else "❌ INVALID"
        print(f"[{status}] {r['file']} — Scenario: {r['scenario']}")

    # Optionnel : enregistrer dans un fichier JSON
    with open("zip_validation_result.json", "w", encoding="utf-8") as f:
        json.dump(results, f, indent=4)

if __name__ == "__main__":
    ZIP_FILE = "msr_dataset.zip"  # Nom de ton fichier zip ici
    process_zip_file(ZIP_FILE)
