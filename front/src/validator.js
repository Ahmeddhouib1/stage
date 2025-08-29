import React, { useRef, useState } from "react";
import { CSSTransition } from "react-transition-group";
import "./style.css";
import "./transitions.css";

function Validator() {
  const nodeRef = useRef(null);

  const [selectedFile, setSelectedFile] = useState(null);
  const [originalText, setOriginalText] = useState("");
  const [correctedText, setCorrectedText] = useState("");
  const [correctedUrl, setCorrectedUrl] = useState("");
  const [reportUrl, setReportUrl] = useState("");
  const [showResult, setShowResult] = useState(false);

  // Light line-diff (kept from your version)
  const computeLineDiff = (oldStr, newStr, lookahead = 6) => {
    const A = oldStr.replace(/\r\n/g, "\n").split("\n");
    const B = newStr.replace(/\r\n/g, "\n").split("\n");

    let i = 0, j = 0;
    const oldOut = [];
    const newOut = [];
    const equals = (x, y) => x === y;

    while (i < A.length || j < B.length) {
      const a = A[i];
      const b = B[j];

      if (i < A.length && j < B.length && equals(a, b)) {
        oldOut.push({ text: a, type: "same" });
        newOut.push({ text: b, type: "same" });
        i++; j++;
        continue;
      }

      let foundInA = -1;
      let foundInB = -1;

      if (j < B.length) {
        for (let k = 1; k <= lookahead && i + k < A.length; k++) {
          if (equals(A[i + k], b)) { foundInA = k; break; }
        }
      }
      if (i < A.length) {
        for (let k = 1; k <= lookahead && j + k < B.length; k++) {
          if (equals(a, B[j + k])) { foundInB = k; break; }
        }
      }

      if (foundInA === -1 && foundInB === -1) {
        if (i < A.length) { oldOut.push({ text: a, type: "changed-old" }); i++; }
        if (j < B.length) { newOut.push({ text: b, type: "changed" }); j++; }
        continue;
      }

      if (foundInA !== -1 && (foundInB === -1 || foundInA <= foundInB)) {
        for (let k = 0; k < foundInA; k++) oldOut.push({ text: A[i + k], type: "removed" });
        i += foundInA;
        continue;
      }

      if (foundInB !== -1) {
        for (let k = 0; k < foundInB; k++) newOut.push({ text: B[j + k], type: "added" });
        j += foundInB;
        continue;
      }
    }

    const maxLen = Math.max(oldOut.length, newOut.length);
    while (oldOut.length < maxLen) oldOut.push({ text: "", type: "same" });
    while (newOut.length < maxLen) newOut.push({ text: "", type: "same" });

    return { oldOut, newOut };
  };

  const [diffOld, setDiffOld] = useState([]);
  const [diffNew, setDiffNew] = useState([]);

  const handleFileChange = (event) => {
    const file = event.target.files[0];
    setSelectedFile(file || null);

    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => setOriginalText(e.target.result || "");
      reader.readAsText(file, "utf-8");
    } else {
      setOriginalText("");
    }
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
        let msg = "Server error.";
        try {
          const err = await response.json();
          if (err?.error) msg = err.error;
        } catch (_) {}
        throw new Error(msg);
      }

      const data = await response.json();
      setCorrectedUrl(data.corrected_file_url);
      setReportUrl(data.report_file_url);

      const correctedRes = await fetch(`http://localhost:8000${data.corrected_file_url}`);
      const corrected = await correctedRes.text();
      setCorrectedText(corrected);

      const { oldOut, newOut } = computeLineDiff(originalText, corrected);
      setDiffOld(oldOut);
      setDiffNew(newOut);

      setShowResult(true);
    } catch (error) {
      alert("❌ Error: " + error.message);
    }
  };

  const handleDownload = (type) => {
    let url = "";
    let filename = "";

    if (type === "feature") {
      url = correctedUrl;
      filename = "corrected_" + (selectedFile?.name || "file.feature");
    } else if (type === "report") {
      url = reportUrl;
      const base = (selectedFile?.name || "file.feature").replace(/\.feature$/i, "");
      filename = `report_${base}.json`;
    }

    const fullUrl = `http://localhost:8000${url}`;
    const a = document.createElement("a");
    a.href = fullUrl;
    a.download = filename;
    a.click();
  };

  const handleBack = () => {
    setShowResult(false);
    setSelectedFile(null);
    setOriginalText("");
    setCorrectedText("");
    setCorrectedUrl("");
    setReportUrl("");
    setDiffOld([]);
    setDiffNew([]);
  };

  const classForOld = (t) =>
    t === "same" ? "" :
    t === "removed" ? "line-removed" :
    t === "changed-old" ? "line-changed-old" : "";

  const classForNew = (t) =>
    t === "same" ? "" :
    t === "added" ? "line-added" :
    t === "changed" ? "line-changed" : "";

  return (
    <section className="validator-container">
      <div className="stars"></div>
      <div className="twinkling"></div>

      <CSSTransition in appear timeout={500} classNames="fade" nodeRef={nodeRef}>
        <div className="validator-content" ref={nodeRef}>
          {!showResult ? (
            <>
              <h1>🧠 AI Test Validator</h1>
              <p className="subtitle">Drop your <b>.feature</b> file and let AI enhance it.</p>

              <div className="button-stack">
                <div className="file-upload-wrapper">
                  <label htmlFor="file-upload" className="custom-file-upload compact">
                    📁 Choose a .feature File
                  </label>
                  <input id="file-upload" type="file" accept=".feature" onChange={handleFileChange} />
                </div>

                <button className="analyse-button compact" onClick={handleAnalyse} disabled={!selectedFile}>
                  🚀 Analyze File
                </button>
              </div>

              {selectedFile && <p className="file-name">✅ Selected: {selectedFile.name}</p>}
            </>
          ) : (
            <>
              <button className="back-button" onClick={handleBack}>⬅ Back</button>
              <h2>✅ Results</h2>

              <div className="split-view">
                <div className="panel">
                  <div className="panel-header">Original (red = removed/changed)</div>
                  <pre className="code-block" aria-label="Original feature">
                    {diffOld.length === 0
                      ? originalText
                      : diffOld.map((line, idx) => (
                          <div key={idx} className={classForOld(line.type)}>
                            {line.text || " "}
                          </div>
                        ))}
                  </pre>
                </div>

                <div className="panel">
                  <div className="panel-header">Corrected (green = added/changed)</div>
                  <pre className="code-block" aria-label="Corrected feature">
                    {diffNew.length === 0
                      ? correctedText
                      : diffNew.map((line, idx) => (
                          <div key={idx} className={classForNew(line.type)}>
                            {line.text || " "}
                          </div>
                        ))}
                  </pre>
                </div>
              </div>

              <div className="download-buttons">
                <button className="cssbuttons-io-button" onClick={() => handleDownload("feature")}>
                  <svg viewBox="0 0 512 512" fill="white" height="1.3em">
                    <path d="M256 0C114.6 0 0 114.6 0 256s114.6 256 256 256 256-114.6 256-256S397.4 0 256 0zM256 472c-119.4 0-216-96.6-216-216S136.6 40 256 40s216 96.6 216 216-96.6 216-216 216zm-24-136h48v-96h64l-88-88-88 88h64v96z"/>
                  </svg>
                  <span>Corrected File</span>
                </button>

                <button className="cssbuttons-io-button" onClick={() => handleDownload("report")}>
                  <svg viewBox="0 0 512 512" fill="white" height="1.3em">
                    <path d="M256 0C114.6 0 0 114.6 0 256s114.6 256 256 256 256-114.6 256-256S397.4 0 256 0zM256 472c-119.4 0-216-96.6-216-216S136.6 40 256 40s216 96.6 216 216-96.6 216-216 216zm-24-136h48v-96h64l-88-88-88 88h64v96z"/>
                  </svg>
                  <span>Report JSON</span>
                </button>
              </div>

              <div className="recommendation-box">
                <h3>🔎 AI Recommendations</h3>
                <ul>
                  <li>✅ Use consistent Gherkin structure.</li>
                  <li>🧪 Avoid vague steps like “click on button”.</li>
                  <li>🤖 Let AI guide your scenario quality.</li>
                </ul>
              </div>
            </>
          )}
        </div>
      </CSSTransition>
    </section>
  );
}

export default Validator;
