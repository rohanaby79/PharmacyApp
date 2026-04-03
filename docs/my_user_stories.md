# Bogdan's Assigned User Stories: Transmission & Response

### Story 7: Secure Electronic Transmission
**As a doctor,** I want to transmit the prescription via a secure API so the pharmacy can begin filling it immediately.
* **Acceptance Criteria:** * Uses HTTPS/REST for all outgoing data.
    * Status updates to "In-Transit" immediately after sending.

### Story 8: Standardized Payload Formatting
**As a system,** I want to format the prescription into a standardized JSON structure so that various pharmacy software providers can interpret the data.
* **Acceptance Criteria:** * Maps data to FHIR/JSON compatible schema.
    * System validates that required fields (Medication, Dosage) are present before sending.

### Story 11: Receive Pharmacy Confirmation
**As a doctor,** I want to receive a digital receipt from the pharmacy so that I know the order was successfully entered into their queue.
* **Acceptance Criteria:** * Captures the HTTP 201 "Created" response from the pharmacy.
    * Status updates to "Received" in the doctor's dashboard.

### Story 13: Handle Rejection & Error Messages
**As a doctor,** I want to be notified if the pharmacy rejects a prescription so that I can address clinical or insurance issues quickly.
* **Acceptance Criteria:** * Captures pharmacy error codes.
    * Triggers a notification in the UI.
    * Allows the doctor to edit the original data and resend.
