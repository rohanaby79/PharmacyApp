# Pharmacy Prescription Integration System
**CSC 411 — Senior Software Engineering Project**

A REST API for managing pharmacy prescriptions. Built with Ruby on Rails following an MVC architecture.

---

## What This Project Does

This system allows doctors to:
- Add medication instructions to a prescription (Story 6)
- Generate a printable prescription document (Story 16)
- View the history/timeline of a prescription (Story 19)

---

## How to Run

**1. Make sure Ruby and Rails are installed**
```bash
ruby -v
rails -v
```

**2. Install dependencies**
```bash
bundle install
```

**3. Start the server**
```bash
rails server
```

You should see:
```
* Listening on http://127.0.0.1:3000
```

> Keep this terminal open while testing. Press `Ctrl + C` to stop the server.

---

## How to Test

Open your browser and go to **http://localhost:3000** to see the dashboard.

For the POST request (Story 6), use the **REST Client** extension in VS Code:
1. Install "REST Client" from the VS Code Extensions panel
2. Open the `test.http` file in this project
3. Click **Send Request** above any block while the server is running

---

## API Endpoints

| Method | URL | Story | Description |
|--------|-----|-------|-------------|
| `POST` | `/prescriptions/:id/instructions` | Story 6 | Add medication instructions |
| `GET`  | `/prescriptions/:id/print`        | Story 16 | View printable prescription |
| `GET`  | `/prescriptions/:id/history`      | Story 19 | View prescription timeline |

**Example URLs:**
- http://localhost:3000/prescriptions/RX-001/print
- http://localhost:3000/prescriptions/RX-002/history

---

## Test Patients (Seed Data)

Two patients are pre-loaded for immediate testing.

| ID | Patient | Medication | Status |
|----|---------|------------|--------|
| RX-001 | John Smith | Amoxicillin | Pending |
| RX-002 | Maria Gonzalez | Metformin | Sent to Pharmacy |

> Data is defined in `app/models/prescription.rb` and resets on every server restart.

---

## Story 6 — Adding Instructions (POST Request)

Use the `test.http` file or paste this:

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
pharmacy-rails/
├── app/
│   ├── controllers/
│   │   ├── home_controller.rb          ← Dashboard homepage
│   │   └── prescriptions_controller.rb ← Handles all 3 story endpoints
│   ├── models/
│   │   └── prescription.rb             ← Patient data + in-memory storage
│   └── services/
│       └── prescription_service.rb     ← Business logic for all 3 stories
├── config/
│   └── routes.rb                       ← Maps URLs to controllers
├── test.http                           ← API test file (REST Client)
└── README.md
```

---

## Tech Stack

- **Ruby** — Programming language
- **Rails 8** — Web framework
- **MVC Architecture** — Models, Views (HTML), Controllers
- **In-memory storage** — No database needed; data lives in a Ruby array

---

*Pharmacy Prescription Integration System — CSC 411 Senior Project*
