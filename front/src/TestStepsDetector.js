import React, { useState } from "react";
import "./style.css";

function TestStepsDetector() {
  const [selectedFile, setSelectedFile] = useState(null);
  const [result, setResult] = useState(null);

  const handleDetect = async () => {
    if (!selectedFile) return;

    const formData = new FormData();
    formData.append("file", selectedFile);

    try {
      const res = await fetch("http://localhost:8000/detect", {
        method: "POST",
        body: formData,
      });
      const data = await res.json();
      setResult(data);
    } catch (err) {
      alert("Error: " + err.message);
    }
  };

  return (
    <section className="validator-container">
      <div className="stars"></div>
      <div className="twinkling"></div>

      <div className="validator-content">
        <h1>🧪 Test Your Code</h1>
        <p className="subtitle">Upload a <b>.feature</b> file to check required steps & order.</p>

        <div className="button-stack">
          <div className="file-upload-wrapper">
            <label htmlFor="file-input-detect" className="custom-file-upload compact">
              📁 Choose a .feature File
            </label>
            <input
              id="file-input-detect"
              type="file"
              accept=".feature"
              onChange={(e) => setSelectedFile(e.target.files[0])}
            />
          </div>

          <button
            className="analyse-button compact"
            onClick={handleDetect}
            disabled={!selectedFile}
          >
            🚀 Analyze File
          </button>
        </div>

        {selectedFile && <p className="file-name">✅ Selected: {selectedFile.name}</p>}

        {result && (
          <div className="recommendation-box">
            <h3>✅ Detection Result</h3>
            <p><strong>Scenario:</strong> {result.scenario}</p>
            <p><strong>Steps Found:</strong> {result.found_steps?.join(", ") || "None"}</p>
            <p><strong>Missing:</strong> {result.missing_steps?.join(", ") || "None"}</p>
            <p><strong>Is Order Correct:</strong> {result.is_order_correct ? "✅ Yes" : "❌ No"}</p>
            <p><strong>Valid Script:</strong> {result.is_valid_script ? "✅ Valid" : "❌ Invalid"}</p>
          </div>
        )}
      </div>
    </section>
  );
}

export default TestStepsDetector;
