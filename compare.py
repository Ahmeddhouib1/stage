from difflib import unified_diff

# Chemins des fichiers
original_file = "TC01.feature"
corrected_file = "corrected.feature"
diff_output_file = "feature_diff.txt"

# Lire les fichiers
with open(original_file, "r", encoding="utf-8") as f1:
    original_lines = f1.readlines()

with open(corrected_file, "r", encoding="utf-8") as f2:
    corrected_lines = f2.readlines()

# Comparaison ligne par ligne
diff = list(unified_diff(
    original_lines,
    corrected_lines,
    fromfile="Original",
    tofile="Corrected",
    lineterm=""
))

# Sauvegarder le diff dans un fichier
with open(diff_output_file, "w", encoding="utf-8") as f:
    f.write("\n".join(diff))

# Affichage console
if diff:
    print("📋 Différences détectées entre original et corrigé :")
    print("\n".join(diff))
    print(f"\n📝 Résultat complet sauvegardé dans : {diff_output_file}")
else:
    print("✅ Aucun changement détecté entre les fichiers.")
