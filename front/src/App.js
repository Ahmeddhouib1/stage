import React, { useState } from "react";
import "./style.css";

function App() {
  const [selectedFile, setSelectedFile] = useState(null);
  const [correctedText, setCorrectedText] = useState("");
  const [showResult, setShowResult] = useState(false);

  const handleFileChange = (event) => {
    setSelectedFile(event.target.files[0]);
  };

  const handleAnalyse = async () => {
    if (!selectedFile) return;

    const formData = new FormData();
    formData.append("file", selectedFile);

    try {
      const response = await fetch("http://localhost:8000/upload", {
        method: "POST",
        body: formData,
      });

      if (!response.ok) {
        throw new Error("Erreur du serveur.");
      }

      const text = await response.text();
      setCorrectedText(text);
      setShowResult(true);
    } catch (error) {
      alert("❌ Erreur : " + error.message);
    }
  };

  const handleDownload = () => {
    const blob = new Blob([correctedText], { type: "text/plain" });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = "corrected_" + selectedFile.name;
    a.click();
    window.URL.revokeObjectURL(url);
  };

  const handleBack = () => {
    setShowResult(false);
    setSelectedFile(null);
    setCorrectedText("");
  };

  return (
    <div className="app">
      {!showResult ? (
        <div className="overlay">
          <h1>✅ <span className="title-highlight">TestFlow Validator</span></h1>
          <p className="subtitle">Analyse intelligente de vos fichiers <b>.feature</b></p>

          <div className="form-group">
            <label htmlFor="file-upload" className="custom-file-upload">
              📂 Choisir un fichier .feature
            </label>
            <input id="file-upload" type="file" onChange={handleFileChange} />

            <button className="analyse-button" onClick={handleAnalyse} disabled={!selectedFile}>
              🚀 Analyser le fichier
            </button>
          </div>

          {selectedFile && (
            <p className="file-name">✅ Fichier sélectionné : {selectedFile.name}</p>
          )}
        </div>
      ) : (
        <div className="result-container">
          <button className="back-button" onClick={handleBack}>⬅ Retour</button>

          <h2>✅ Résultat du fichier corrigé</h2>
          <textarea readOnly value={correctedText}></textarea>

          <button onClick={handleDownload}>⬇ Télécharger</button>

          <div className="recommendation-box">
            <h3>🔎 Recommandations :</h3>
            <ul>
              <li>✔️ Utilisez un langage clair et cohérent.</li>
              <li>🧪 Évitez les étapes vagues comme "je clique".</li>
              <li>📘 Respectez la structure Gherkin : Given / When / Then.</li>
            </ul>
          </div>
        </div>
      )}
    </div>
  );
}

export default App;
