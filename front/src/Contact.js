import React from "react";
import emailjs from "emailjs-com";
import "./mainpage.css"; // navbar / background / shared bits

export default function Contact() {
  return (
    <section
      id="contact"
      style={{
        minHeight: "100vh",
        padding: "120px 20px 80px",
        display: "grid",
        placeItems: "center",
        textAlign: "center",
      }}
    >
      <div style={{ width: "100%", maxWidth: 700 }}>
        <h2>📨 Contact Us</h2>
        <form
          onSubmit={(e) => {
            e.preventDefault();
            emailjs
              .sendForm("service_v2etg0g", "template_8teakzv", e.target, "kI1ce8oatZtzr2lv5")
              .then(() => { alert("Message sent!"); e.target.reset(); })
              .catch(() => alert("Failed to send. Please try again."));
          }}
          style={{
            display: "flex",
            flexDirection: "column",
            gap: "15px",
            width: "100%",
            margin: "0 auto",
          }}
        >
          <input type="text" name="name" placeholder="Your Name" required />
          <input type="email" name="email" placeholder="Your Email" required />
          <textarea name="message" placeholder="Your Message" rows="5" required />
          <button type="submit" className="analyse-button">📤 Send Message</button>
        </form>
      </div>
    </section>
  );
}
