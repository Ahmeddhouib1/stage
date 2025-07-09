import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
import pickle

# Charger les données d'entraînement (assurez-vous que tc_dataset.csv est dans le même dossier)
df = pd.read_csv("tc_dataset.csv")  # colonnes attendues : 'sentence', 'label'

# Séparer les phrases et leurs labels
X = df['sentence']
y = df['label']

# Transformer les phrases en vecteurs TF-IDF
vectorizer = TfidfVectorizer()
X_vect = vectorizer.fit_transform(X)

# Entraîner un modèle de classification
model = LogisticRegression()
model.fit(X_vect, y)

# Sauvegarder le modèle et le vectorizer pour les utiliser ensuite
with open("tc_model.pkl", "wb") as f:
    pickle.dump(model, f)

with open("tc_vectorizer.pkl", "wb") as f:
    pickle.dump(vectorizer, f)

print("✅ Modèle entraîné et sauvegardé avec succès.")
