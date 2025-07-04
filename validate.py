import re
import json

# === Ordre requis des étapes MSR ===
REQUIRED_ORDER = [
    "Precondition",
    "Send Amount",
    "Card Swipe",
    "Data Parsing",
    "Confirmation",
    "CVM Process",
    "Transaction Completion"
]

# === Classifie un bloc de test en fonction de son contenu ===
def classify_block(block: str) -> str:
    block_lower = block.lower()
    if  "31.x" in block_lower:
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

# === Extrait la ligne après 'Scenario Outline:' ===
def extract_scenario_line(content: str) -> str:
    match = re.search(r'Scenario Outline:\s*(.+)', content)
    return match.group(1).strip() if match else "Not found"

# === Fonction principale de validation ===
def validate_feature_script(file_path: str) -> dict:
    with open(file_path, "r", encoding="utf-8") as f:
        lines = f.readlines()
        content = ''.join(lines)

    scenario_line = extract_scenario_line(content)

    # Ignorer les lignes de tag (@...)
    lines = [line for line in lines if not line.strip().startswith("@")]

    # Regrouper les blocs (Given/When/Then/And + lignes suivantes)
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
    debug = []

    for block in blocks:
        label = classify_block(block)
        if label == "Unclassified":
            continue

        debug.append({
            "block": block.split("\n")[0].strip(),
            "label": label
        })

        # Éviter les doublons (même non consécutifs)
        if label in REQUIRED_ORDER and label not in found_steps:
            found_steps.append(label)

    missing_steps = [step for step in REQUIRED_ORDER if step not in found_steps]
    is_order_correct = found_steps == REQUIRED_ORDER

    return {
        "scenario": scenario_line,
        "found_steps": found_steps,
        "missing_steps": missing_steps,
        "is_order_correct": is_order_correct,
        "is_valid_script": is_order_correct and not missing_steps,
        "debug": debug
    }

# === Exécution depuis VSCode / terminal ===
if __name__ == "__main__":
    INPUT_FILE = "test1.feature"
    OUTPUT_FILE = "validation_result.json"

    result = validate_feature_script(INPUT_FILE)

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(result, f, indent=4)

    print("✅ Résultat de validation :")
    print(json.dumps(result, indent=4))
