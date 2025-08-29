import React from "react";
import "./style.css";

export default function Help() {
  return (
    <section className="validator-container">
      <div className="stars"></div>
      <div className="twinkling"></div>

      <div className="validator-content help-container">
        <h1>🆘 Help & User Guide</h1>
        <p className="help-subtitle">
          This guide walks you through the full workflow: <b>Validation → Detection → Contact</b>.
        </p>

        <nav className="help-toc">
          <a href="#quickstart">🚀 Quick Start</a>
          <a href="#validation">🧠 Validation</a>
          <a href="#detection">🧪 Detect Steps</a>
          <a href="#downloads">⬇️ Downloads</a>
          <a href="#sample">📄 Sample .feature</a>
          <a href="#faq">❓ FAQ</a>
          <a href="#troubleshooting">🛠️ Troubleshooting</a>
          <a href="#privacy">🔒 Privacy</a>
        </nav>

        <div className="help-grid">
          <section id="quickstart" className="help-card">
            <h2>🚀 Quick Start</h2>
            <ol className="help-steps">
              <li>Go to <b>Validator</b> → Choose your <code>.feature</code> file → click <b>Analyze File</b>.</li>
              <li>Review the <b>Original</b> (left) vs <b>Corrected</b> (right). Green = added/changed, Red = removed/changed.</li>
              <li>Optionally go to <b>Detect Steps</b> → upload the same file → check required steps & order.</li>
              <li>Use <b>Download</b> buttons to get the corrected file and JSON report.</li>
              <li>Questions? Go to <b>Contact</b> and send us a message.</li>
            </ol>
          </section>

          <section id="validation" className="help-card">
            <h2>🧠 Validation (Syntax & Structure)</h2>
            <ul className="help-bullets">
              <li>Accepts files with the extension <code>.feature</code> (Gherkin).</li>
              <li>AI corrects <b>syntax only</b> — it <u>doesn’t change your business logic</u>.</li>
              <li>Results render side‑by‑side:
                <ul>
                  <li><b>Original</b> panel: red highlights for removed/changed lines.</li>
                  <li><b>Corrected</b> panel: green highlights for added/changed lines.</li>
                </ul>
              </li>
              <li>The <b>JSON report</b> includes:
                <ul>
                  <li><code>errors</code> — critical syntax issues found</li>
                  <li><code>good_practices</code> — recommendations we detected</li>
                </ul>
              </li>
            </ul>
            <p className="help-note">
              If the server returns an error, the UI shows the <b>real message</b> it got from the backend so you can fix quickly.
            </p>
          </section>

          <section id="detection" className="help-card">
            <h2>🧪 Detect Steps (ARC‑SI pattern)</h2>
            <p>
              This tool checks your scenario for required steps and their order (e.g., <i>Precondition</i>, <i>Send Amount</i>, <i>Card Swipe</i>, <i>Data Parsing</i>, <i>Confirmation</i>, <i>CVM Process</i>, <i>Transaction Completion</i>).
            </p>
            <ol className="help-steps">
              <li>Open <b>Detect Steps</b>.</li>
              <li>Upload a <code>.feature</code> file and click <b>Analyze File</b>.</li>
              <li>Read the results:
                <ul>
                  <li><b>Steps Found</b> / <b>Missing</b></li>
                  <li><b>Is Order Correct</b> (evaluates expected sequence)</li>
                  <li><b>Valid Script</b> (all steps present + correct order)</li>
                </ul>
              </li>
            </ol>
          </section>

          <section id="downloads" className="help-card">
            <h2>⬇️ Downloads</h2>
            <ul className="help-bullets">
              <li><b>Corrected File</b>: the fixed <code>.feature</code> (syntax‑only changes).</li>
              <li><b>Report JSON</b>: structured list of <code>errors</code> and <code>good_practices</code>.</li>
            </ul>
            <p className="help-note">
              Files are served from the backend’s <code>/download/&lt;filename&gt;</code> route.
            </p>
          </section>

          <section id="sample" className="help-card">
            <h2>📄 Sample <code>.feature</code> file</h2>
            <pre className="help-code">
{`Feature: Payment validation
  As a cashier
  I want to validate a card payment
  So that the transaction is approved

  Scenario: Approve a magnetic card payment
    Given I use upp-ws transaction endpoint
    When I send upp-ws request.
    And Axium swipe magnetic card
    Then I should receive upp-ws event subset within 50s
    And I send upp-ws event_ack with status "ok"
    And when I enter pin
    When I send upp-ws event_ack with status "ok"`}
            </pre>
            <p className="help-note">
              Keep steps consistent with your expected flow so the detector can validate presence & order.
            </p>
          </section>

          <section id="faq" className="help-card">
            <h2>❓ FAQ</h2>

            <details className="help-faq">
              <summary>What file types are supported?</summary>
              <div>Only <code>.feature</code> files (Gherkin syntax) are supported in Validator and Detect Steps.</div>
            </details>

            <details className="help-faq">
              <summary>Does the AI change my business rules?</summary>
              <div>No. It corrects <b>syntax/format</b> only, preserving your scenario’s logic.</div>
            </details>

            <details className="help-faq">
              <summary>I got “500 Server Error”. What do I do?</summary>
              <div>
                Ensure the backend is running on <code>http://localhost:8000</code>.
                Check your <code>.env</code> has <code>TOGETHER_API_KEY</code>.
                The UI shows the backend error message; fix according to that hint.
              </div>
            </details>

            <details className="help-faq">
              <summary>Where are my downloads saved?</summary>
              <div>Files are generated under the backend <code>corrected/</code> folder and served via <code>/download/…</code>.</div>
            </details>

            <details className="help-faq">
              <summary>How do I contact support?</summary>
              <div>Use the <b>Contact</b> page to send us a message directly from the app.</div>
            </details>
          </section>

          <section id="troubleshooting" className="help-card">
            <h2>🛠️ Troubleshooting</h2>
            <ul className="help-bullets">
              <li><b>Frontend 404 for video or images</b>: ensure static files (e.g., <code>video.mp4</code>) exist and import paths are correct.</li>
              <li><b>500 on /upload</b>: backend crashed while parsing model JSON — check your backend logs.</li>
              <li><b>CORS issues</b>: Flask includes <code>CORS(app)</code>. If you changed ports/hosts, confirm they match.</li>
              <li><b>Nothing happens after Analyze</b>: open DevTools → Network → review response body.</li>
            </ul>
          </section>

          <section id="privacy" className="help-card">
            <h2>🔒 Privacy</h2>
            <p>
              Your uploaded files are stored locally under <code>uploads/</code> during processing; generated outputs live under <code>corrected/</code>. 
              Clean them anytime by deleting those folders.
            </p>
          </section>
        </div>
      </div>
    </section>
  );
}
