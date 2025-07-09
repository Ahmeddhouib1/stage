import re
import json

# Étapes ARC-SI attendues dans l'ordre
expected_steps = [
    ("Precondition", r"Given I use upp-ws transaction endpoint"),
    ("Send Amount", r"When I send upp-ws request."),
    ("Card Swipe", r"When Axium swipe magnetic card"),
    ("Data Parsing", r"Then I should receive upp-ws event subset within 50s"),
    ("Confirmation", r"And I send upp-ws event_ack with status \"ok\""),
    ("CVM Process", r"And when I enter pin"),
    ("Transaction Completion", r"When I send upp-ws event_ack with status \"ok\"")
]

# 🔁 Charge ton contenu .feature ici (ex: lire un fichier)
with open("test4.feature", "r", encoding="utf-8") as file:
    feature_content = file.read()

# 🎯 Détection des étapes
found_steps = []
debug = []

for name, pattern in expected_steps:
    if re.search(pattern, feature_content, re.IGNORECASE | re.DOTALL):
        found_steps.append(name)
        debug.append({"label": name, "pattern": pattern, "found": True})
    else:
        debug.append({"label": name, "pattern": pattern, "found": False})

# 🔍 Étapes manquantes et ordre
missing_steps = [name for name, _ in expected_steps if name not in found_steps]
expected_labels = [label for label, _ in expected_steps]
found_order = [label for label in expected_labels if label in found_steps]
is_order_correct = found_order == sorted(found_order, key=lambda x: expected_labels.index(x))

# ✅ Résultat JSON
result = {
    "scenario": "Nom de ton scénario",
    "found_steps": found_steps,
    "missing_steps": missing_steps,
    "is_order_correct": is_order_correct,
    "is_valid_script": len(missing_steps) == 0 and is_order_correct,
    "debug": debug
}

# 💾 Sauvegarde du résultat
with open("arc_si_detection_result.json", "w", encoding="utf-8") as f:
    json.dump(result, f, indent=2, ensure_ascii=False)

print("Résultat écrit dans arc_si_detection_result.json")
