from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
import os
from model import lancer_validation

app = Flask(__name__)
CORS(app)

UPLOAD_FOLDER = 'uploads'
CORRECTED_FOLDER = 'corrected'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(CORRECTED_FOLDER, exist_ok=True)

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'error': 'Aucun fichier trouvé'}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'Nom de fichier vide'}), 400

    filepath = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(filepath)

    try:
        corrected_path = lancer_validation(filepath)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

    return send_file(corrected_path, as_attachment=False)

if __name__ == '__main__':
    app.run(port=8000)
