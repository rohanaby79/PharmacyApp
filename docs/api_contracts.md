# Integration Architecture: REST API Contract

### Overview
This document defines the communication standard between our EHR and external Pharmacy Systems.

### Endpoint: POST /api/v1/prescriptions/transmit
**Purpose:** Sends a completed prescription to the pharmacy.

**Request Headers:**
* `Authorization: Bearer <JWT_TOKEN>` (Security from Role 5)
* `Content-Type: application/json`

**Request Body (JSON):**
* `prescription_id`: Integer
* `medication_data`: Object (Mapped by Role 6)
* `timestamp`: ISO8601 String

**Success Response (201 Created):**
```json
{
  "status": "success",
  "pharmacy_confirmation_id": "RX-9921-ABC",
  "estimated_fill_time": "2 hours"
}
