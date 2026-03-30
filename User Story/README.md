# Pharmacy Prescription Integration System
**CSC 411 — Senior Software Engineering Project**

A backend API for managing pharmacy prescriptions. Built with Node.js and Express.js following an MVC architecture.

---

## What This Project Does

This system allows doctors to:
- Add medication instructions to a prescription (Story 6)
- Generate a printable prescription document (Story 16)
- View the history/timeline of a prescription (Story 19)

---

## How to Run

**1. Make sure Node.js is installed**
```bash
node -v
```
If you don't see a version number, download Node.js at [nodejs.org](https://nodejs.org).

**2. Install dependencies**
```bash
npm install
```

**3. Start the server**
```bash
node app.js
```

You should see:
```
✅ Server is running at http://localhost:3000
```

> Keep this terminal open while testing. Press `Ctrl + C` to stop the server.

---

## How to Test

Open your browser and go to **http://localhost:3000** to see the dashboard.

From there you can click directly into the print and history pages for both patients.

For the POST request (Story 6), use the **REST Client** extension in VS Code:
1. Install "REST Client" from the VS Code Extensions panel
2. Open the `test.http` file included in this project
3. Click **Send Request** above any request block

---

## API Endpoints

| Method | URL | Story | Description |
|--------|-----|-------|-------------|
| `POST` | `/prescriptions/:id/instructions` | Story 6 | Add medication instructions |
| `GET` | `/prescriptions/:id/print` | Story 16 | View printable prescription |
| `GET` | `/prescriptions/:id/history` | Story 19 | View prescription timeline |

**Example URLs using the seed data:**
- http://localhost:3000/prescriptions/RX-001/print
- http://localhost:3000/prescriptions/RX-002/history

---

## Test Patients (Seed Data)

Two fake patients are pre-loaded so you can test immediately without setting anything up.

| ID | Patient | Medication | Status |
|----|---------|------------|--------|
| RX-001 | John Smith | Amoxicillin | Pending |
| RX-002 | Maria Gonzalez | Metformin | Sent to Pharmacy |

> This data is defined in `models/Prescription.js` and resets every time the server restarts.

---

## Story 6 — Adding Instructions (POST Request)

Use the `test.http` file or paste this into it:

```http
POST http://localhost:3000/prescriptions/RX-001/instructions
Content-Type: application/json

{
  "dosage": "500mg",
  "frequency": "Twice daily",
  "duration": "7 days",
  "notes": "Take with food"
}
```

`dosage`, `frequency`, and `duration` are required. `notes` is optional.

---

## Project Structure

```
User Story/
├── app.js                          ← Starts the server
├── package.json                    ← Project dependencies
├── test.http                       ← API test file (REST Client)
├── models/
│   └── Prescription.js             ← Patient data + in-memory storage
├── services/
│   └── prescriptionService.js      ← Business logic for all 3 stories
├── controllers/
│   └── prescriptionController.js   ← Handles requests and responses
└── routes/
    └── prescriptionRoutes.js       ← Maps URLs to controllers
```

---

## Tech Stack

- **Node.js** — JavaScript runtime
- **Express.js** — Web framework
- **MVC Architecture** — Separation of Models, Views, and Controllers
- **In-memory storage** — No database needed; data lives in a JavaScript array

---

*Pharmacy Prescription Integration System — CSC 411 Senior Project*
