import React from "react";
import "./welcome.css";

function Welcome() {
  return (
    <section className="welcome-container">
      <div className="welcome-box">
        <h1 className="welcome-title">
          🚀 Welcome to <span className="highlight">TestFlow Validator</span>
        </h1>

        <p className="welcome-text">
          A powerful <span className="highlight">AI tool</span> by Telnet to
          enhance and verify your test scripts.
        </p>

        <p className="welcome-sub">
          <em>Are you ready to lead your tests to the next level?</em>
        </p>

        <div className="welcome-actions">
          <a className="start-btn" href="/validator">✅ Start Validating</a>
          <a className="start-btn alt" href="/detect">🧪 Detect Steps</a>
        </div>
      </div>
    </section>
  );
}

export default Welcome;
