import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report
import joblib

# === Chargement du dataset
csv_path = "augmented_combined_dataset.csv"
df = pd.read_csv(csv_path)

# === Nettoyage
df = df.dropna(subset=["block_text", "block_label"])
print("📊 Répartition des classes :")
print(df["block_label"].value_counts())

# === Vectorisation TF-IDF
vectorizer = TfidfVectorizer(ngram_range=(1, 2), max_features=5000)
X = vectorizer.fit_transform(df["block_text"])
y = df["block_label"]

# === Séparation entraînement / test
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, stratify=y, random_state=42)

# === Modèle de classification
clf = LogisticRegression(max_iter=1000, solver="liblinear")
clf.fit(X_train, y_train)

# === Évaluation
y_pred = clf.predict(X_test)
print("\n📈 Rapport de classification :")
print(classification_report(y_test, y_pred))

# === Sauvegarde du modèle
joblib.dump(clf, "gherkin_classifier.pkl")
joblib.dump(vectorizer, "gherkin_vectorizer.pkl")

print("✅ Modèle et vectoriseur sauvegardés avec succès.")
