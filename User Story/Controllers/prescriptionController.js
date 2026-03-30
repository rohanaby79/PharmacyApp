/**
 * Prescription Controller
 * Handles incoming HTTP requests and sends back responses.
 * Delegates all business logic to the prescriptionService.
 *
 * Rule: Controllers should NOT contain business logic —
 * they only read the request, call the service, and send a response.
 */

const prescriptionService = require("../services/prescriptionService");

// ─────────────────────────────────────────────────────────────
// STORY 6 — POST /prescriptions/:id/instructions
// ─────────────────────────────────────────────────────────────

/**
 * Adds structured medication instructions to a prescription.
 *
 * Expected request body:
 * {
 *   "dosage": "500mg",
 *   "frequency": "Twice daily",
 *   "duration": "7 days",
 *   "notes": "Take with food"      ← optional
 * }
 */
const addInstructions = (req, res) => {
  const { id } = req.params;
  const instructionData = req.body;

  const result = prescriptionService.addInstructions(id, instructionData);

  if (!result.success) {
    // 404 if prescription not found, 400 if validation fails
    const statusCode = result.error === "Prescription not found." ? 404 : 400;
    return res.status(statusCode).json({ success: false, message: result.error });
  }

  return res.status(200).json({
    success: true,
    message: "Medication instructions added successfully.",
    prescription: result.prescription,
  });
};

// ─────────────────────────────────────────────────────────────
// STORY 16 — GET /prescriptions/:id/print
// ─────────────────────────────────────────────────────────────

/**
 * Returns a fully formatted HTML document for printing.
 * The browser (or Postman) will receive raw HTML back.
 */
const printPrescription = (req, res) => {
  const { id } = req.params;

  const result = prescriptionService.generatePrintablePrescription(id);

  if (!result.success) {
    return res.status(404).json({ success: false, message: result.error });
  }

  // Send the HTML string with the correct Content-Type header
  // so browsers can render it directly
  res.setHeader("Content-Type", "text/html");
  return res.status(200).send(result.html);
};

// ─────────────────────────────────────────────────────────────
// STORY 19 — GET /prescriptions/:id/history
// ─────────────────────────────────────────────────────────────

/**
 * Returns the full chronological status history for a prescription.
 * Used to track prescription progress over time.
 */
const getPrescriptionHistory = (req, res) => {
  const { id } = req.params;

  const result = prescriptionService.getPrescriptionHistory(id);

  if (!result.success) {
    return res.status(404).json({ success: false, message: result.error });
  }

  // Send as HTML so the browser renders it as a proper page
  res.setHeader("Content-Type", "text/html");
  return res.status(200).send(result.html);
};

module.exports = {
  addInstructions,
  printPrescription,
  getPrescriptionHistory,
};
