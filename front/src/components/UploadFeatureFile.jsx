import React, { useState } from 'react';
import axios from 'axios';

const UploadFeatureFile = ({ onResult }) => {
  const [file, setFile] = useState(null);
  const [loading, setLoading] = useState(false);

const handleUpload = async () => {
  const formData = new FormData();
  formData.append('file', selectedFile);

  const response = await fetch('http://localhost:5000/upload', {
    method: 'POST',
    body: formData,
  });

  if (!response.ok) {
    alert("Erreur d'envoi");
    return;
  }

  // Convertir en fichier et déclencher téléchargement
  const blob = await response.blob();
  const downloadUrl = window.URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = downloadUrl;
  link.download = 'corrected_' + selectedFile.name;
  document.body.appendChild(link);
  link.click();
  link.remove();
};


  return (
    <div className="text-center">
      <label className="block mb-3 text-lg font-medium text-gray-700">📁 Sélectionnez un fichier .feature</label>

      <input
        type="file"
        accept=".feature"
        onChange={(e) => setFile(e.target.files[0])}
        className="block w-full mb-6 text-sm text-gray-600 
                   file:mr-4 file:py-3 file:px-6 
                   file:rounded-xl file:border-0 
                   file:bg-indigo-100 file:text-indigo-700 
                   hover:file:bg-indigo-200 transition"
      />

      <button
        onClick={handleUpload}
        disabled={!file || loading}
        className={`w-full py-3 px-6 text-lg rounded-xl font-bold text-white tracking-wide transition-all duration-300 
          ${loading ? 'bg-gray-400 cursor-not-allowed' : 'bg-indigo-600 hover:bg-indigo-700 shadow-md hover:shadow-xl'}`}
      >
        {loading ? "Analyse en cours..." : "🚀 Analyser le fichier"}
      </button>
    </div>
  );
};

export default UploadFeatureFile;
