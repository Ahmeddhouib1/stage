from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import os
import re
import traceback
from werkzeug.utils import secure_filename
from model import lancer_validation, ModelRateLimit

app = Flask(__name__)
CORS(app)

UPLOAD_FOLDER = 'uploads'
CORRECTED_FOLDER = 'corrected'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(CORRECTED_FOLDER, exist_ok=True)


@app.route('/upload', methods=['POST'])
def upload_file():
    try:
        if 'file' not in request.files:
            return jsonify({'error': 'Aucun fichier trouvé'}), 400

        file = request.files['file']
        if file.filename == '':
            return jsonify({'error': 'Nom de fichier vide'}), 400

        filename = secure_filename(file.filename)
        filepath = os.path.join(UPLOAD_FOLDER, filename)
        file.save(filepath)

        corrected_path, report_path = lancer_validation(filepath)

        return jsonify({
            "corrected_file_url": f"/download/{os.path.basename(corrected_path)}",
            "report_file_url": f"/download/{os.path.basename(report_path)}"
        }), 200

    except ModelRateLimit as e:
        # Clean 429 for rate limiting (Together AI or local gate)
        return jsonify({
            "error": str(e),
            "code": 429
        }), 429

    except Exception as e:
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500


@app.route('/download/<path:filename>', methods=['GET'])
def download_file(filename):
    # serve from CORRECTED_FOLDER (both corrected feature + report)
    return send_from_directory(CORRECTED_FOLDER, filename, as_attachment=True)


# Health check
@app.route('/health', methods=['GET'])
def health():
    return "ok"


# --------- Optional: ARC-SI step detector (regex-based) ----------
@app.route('/detect', methods=['POST'])
def detect_steps():
    if 'file' not in request.files:
        return jsonify({'error': 'No file'}), 400

    file = request.files['file']
    content = file.read().decode("utf-8", errors="ignore")

    expected_steps = [
        ("Precondition", r"Given I use upp-ws transaction endpoint"),
        ("Send Amount", r"When I send upp-ws request\."),
        ("Card Swipe", r"When Axium swipe magnetic card"),
        ("Data Parsing", r"Then I should receive upp-ws event subset within 50s"),
        ("Confirmation", r"And I send upp-ws event_ack with status \"ok\""),
        ("CVM Process", r"And when I enter pin"),
        ("Transaction Completion", r"When I send upp-ws event_ack with status \"ok\"")
    ]

    found_steps = []
    debug = []
    for name, pattern in expected_steps:
        ok = re.search(pattern, content, re.IGNORECASE | re.DOTALL) is not None
        if ok:
            found_steps.append(name)
        debug.append({"label": name, "pattern": pattern, "found": ok})

    missing_steps = [name for name, _ in expected_steps if name not in found_steps]
    expected_labels = [label for label, _ in expected_steps]
    found_order = [label for label in expected_labels if label in found_steps]
    is_order_correct = found_order == sorted(found_order, key=lambda x: expected_labels.index(x))

    result = {
        "scenario": "Detected scenario",
        "found_steps": found_steps,
        "missing_steps": missing_steps,
        "is_order_correct": is_order_correct,
        "is_valid_script": len(missing_steps) == 0 and is_order_correct,
        "debug": debug
    }
    return jsonify(result), 200


if __name__ == '__main__':
    # Keep default 127.0.0.1 for local dev
    app.run(port=8000)
