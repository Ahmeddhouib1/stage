# 🚀 TestFlow Validator

TestFlow Validator is an AI-powered tool built by Telnet to help QA engineers and developers analyze, validate, and improve Gherkin `.feature` test scripts.  
The platform combines a React frontend with a Flask (Python) backend, connected to LLMs for smart test script correction and validation.

---

## ✨ Features

- 🧠 AI Test Validator  
  Upload a `.feature` file and get an **automatically corrected version** while keeping your business logic intact.

- 🧪 test Steps Detector 
  Check your test scenarios against required steps and validate their order and completeness.

- 🔎 Side-by-side Comparison  
  Visual diff view of Original vs Corrected scripts with color highlights:
  - 🟥 Red = removed/changed lines  
  - 🟩 Green = added/changed lines  

- ⬇️ File Downloads
  - Corrected `.feature` file  
  - JSON report with detected errors & good practices  

- 📨 Contact Form  
  Integrated with EmailJS to send feedback and support requests.

---

## 🖥️ Tech Stack

- Frontend: React.js  
- Styling: CSS3, Neon Futuristic Theme  
- Backend: Python (Flask), Together AI API  
- File Handling: Upload & Download corrected test scripts  
- Email : EmailJS for contact form  

---

## 📂 Project Structure

/front
├── src/
│ ├── App.js
│ ├── Welcome.js
│ ├── Validator.js
│ ├── TestStepsDetector.js
│ ├── Help.js
│ ├── Contact.js
│ ├── video.mp4
│ ├── style.css
│ └── ...
/back
├── app.py
├── model.py
└── corrected/

other files are only the models that i have traits before i have used the openIA API

 FRONT 
cd front
npm install
npm start 

BACK
```bash
cd back
pip install -r requirements.txt
python app.py 

