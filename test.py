import pickle

# Charger le modèle et le vectorizer
with open("tc_model.pkl", "rb") as f:
    model = pickle.load(f)

with open("tc_vectorizer.pkl", "rb") as f:
    vectorizer = pickle.load(f)

# Exemple de paragraphe (texte brut sans triple guillemets)
paragraph = """
Given I perform iconnect-ws reconnection
And I use upp-ws transaction endpoint
When I setup prompt on display: Executing scenario related to credit sale transaction
And I send upp-ws request: payment_type: credit, type: sale
Then I should receive upp-ws response: status: started
Then I Wait until Element title contains "Insert, Swipe or Tap Card"
When I wait 2 seconds
Then I should receive upp-ws event subset within 50s: type: transaction_completed
When I send upp-ws event_ack with status ok
"""

# Nettoyage
def clean_and_split(paragraph):
    lines = paragraph.strip().split("\n")
    return [line.strip() for line in lines if line.strip()]

# Prédiction ligne par ligne
def predict_tc_lines(paragraph):
    lines = clean_and_split(paragraph)
    X_test = vectorizer.transform(lines)
    preds = model.predict(X_test)

    incorrect_lines = [line for line, pred in zip(lines, preds) if pred == 0]
    correct_lines = [line for line, pred in zip(lines, preds) if pred == 1]

    return {
        "total_lines": len(lines),
        "correct_tc_lines": correct_lines,
        "incorrect_lines": incorrect_lines,
        "is_tc_paragraph": len(incorrect_lines) == 0
    }

# Exécution
result = predict_tc_lines(paragraph)
print(result)
