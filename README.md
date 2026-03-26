# Pharmacy Prescription Integration System
**University Software Engineering Project**

A RESTful API built with Node.js and Express.js implementing three user stories from the Pharmacy Prescription Integration System. Uses MVC architecture with in-memory data storage (no database required).

---

## Project Structure

```
pharmacy-prescription-system/
├── app.js                          ← Entry point, sets up Express server
├── package.json
├── models/
│   └── Prescription.js             ← Data structure + in-memory storage
├── services/
│   └── prescriptionService.js      ← Business logic (Story 6, 16, 19)
├── controllers/
│   └── prescriptionController.js   ← HTTP request/response handling
└── routes/
    └── prescriptionRoutes.js       ← URL-to-controller mapping
```

---

## Setup & Run

```bash
# 1. Install dependencies
npm install

# 2. Start the server
npm start

# Server runs at: http://localhost:3000
```

Two seed prescriptions are pre-loaded on startup: **RX-001** and **RX-002**.

---

## API Endpoints

### Story 6 — Add Medication Instructions
**`POST /prescriptions/:id/instructions`**

Attaches structured dosage instructions to an existing prescription.

**Request Body:**
```json
{
  "dosage": "500mg",
  "frequency": "Twice daily",
  "duration": "7 days",
  "notes": "Take with food to reduce stomach upset."
}
```
> `notes` is optional. `dosage`, `frequency`, and `duration` are required.

**Success Response (200):**
```json
{
  "success": true,
  "message": "Medication instructions added successfully.",
  "prescription": {
    "id": "RX-001",
    "medication": "Amoxicillin",
    "instructions": {
      "dosage": "500mg",
      "frequency": "Twice daily",
      "duration": "7 days",
      "notes": "Take with food to reduce stomach upset.",
      "addedAt": "2025-01-10T09:30:00.000Z"
    },
    "..."
  }
}
```

**Error Responses:**
- `400` — Missing required fields
- `404` — Prescription not found

---

### Story 16 — Generate Printable Prescription
**`GET /prescriptions/:id/print`**

Returns a complete, print-ready HTML document for the prescription.

**Example:** `GET /prescriptions/RX-001/print`

**Response:** Raw `text/html` — open directly in a browser or use
Postman's "Visualize" tab to see the rendered document.

The HTML includes:
- Clinic header (name, address, phone)
- Patient information
- Medication name + instructions
- Pharmacy information
- Doctor name, license number, and a signature field

---

### Story 19 — Track Prescription History
**`GET /prescriptions/:id/history`**

Returns a chronological timeline of all status changes for a prescription.

**Example:** `GET /prescriptions/RX-002/history`

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "prescriptionId": "RX-002",
    "patientName": "Maria Gonzalez",
    "medication": "Metformin",
    "currentStatus": "sent_to_pharmacy",
    "totalEvents": 2,
    "history": [
      {
        "status": "pending",
        "message": "Prescription created.",
        "timestamp": "2025-01-11T09:00:00.000Z"
      },
      {
        "status": "sent_to_pharmacy",
        "message": "Prescription sent electronically to QuickFill Drugs.",
        "timestamp": "2025-01-11T09:45:00.000Z"
      }
    ]
  }
}
```

---

## Testing with Postman

### Quick Test Sequence

1. **Check server** — `GET http://localhost:3000/`
2. **Add instructions** — `POST http://localhost:3000/prescriptions/RX-001/instructions`
   - Set Body → raw → JSON, paste request body above
3. **Print prescription** — `GET http://localhost:3000/prescriptions/RX-001/print`
   - Click **Visualize** tab in Postman to see rendered HTML
4. **View history** — `GET http://localhost:3000/prescriptions/RX-002/history`

### Edge Cases to Test
| Test | Endpoint | Expected |
|---|---|---|
| Missing fields | `POST /prescriptions/RX-001/instructions` with `{}` body | 400 error |
| Wrong ID | `GET /prescriptions/RX-999/history` | 404 error |
| Print without instructions | `GET /prescriptions/RX-001/print` (before adding instructions) | HTML with warning |
| RX-002 already has instructions | `GET /prescriptions/RX-002/print` | Full HTML with instructions |

---

## Architecture Notes

| Layer | File | Responsibility |
|---|---|---|
| **Model** | `models/Prescription.js` | Data structure, in-memory store, CRUD helpers |
| **Service** | `services/prescriptionService.js` | Business logic, validation |
| **Controller** | `controllers/prescriptionController.js` | Parse request, call service, send response |
| **Routes** | `routes/prescriptionRoutes.js` | Map URLs to controller functions |

> **Note:** Data resets every time the server restarts — this is by design
> for a college project (no database required).
