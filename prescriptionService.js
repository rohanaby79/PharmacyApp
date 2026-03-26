/**
 * Prescription Service
 * Contains the business logic for each user story.
 * Controllers call these functions — they don't touch the model directly.
 *
 * Stories covered:
 *   Story 6  — Add Medication Instructions
 *   Story 16 — Generate Printable Prescription (HTML)
 *   Story 19 — Track Prescription History
 */

const Prescription = require("../models/Prescription");

// ─────────────────────────────────────────────────────────────
// STORY 6 — Add Medication Instructions
// ─────────────────────────────────────────────────────────────

/**
 * Attaches structured medication instructions to a prescription.
 * Validates that required fields are present before saving.
 *
 * @param {string} id - Prescription ID
 * @param {object} instructionData - { dosage, frequency, duration, notes }
 * @returns {{ success: boolean, prescription?: object, error?: string }}
 */
const addInstructions = (id, instructionData) => {
  const prescription = Prescription.findById(id);

  if (!prescription) {
    return { success: false, error: "Prescription not found." };
  }

  const { dosage, frequency, duration, notes } = instructionData;

  // Validate required fields
  if (!dosage || !frequency || !duration) {
    return {
      success: false,
      error: "Missing required fields: dosage, frequency, and duration are required.",
    };
  }

  // Build the structured instructions object
  const instructions = {
    dosage,
    frequency,
    duration,
    notes: notes || "", // notes are optional
    addedAt: new Date().toISOString(),
  };

  // Save to the prescription record
  const updated = Prescription.update(id, { instructions });

  return { success: true, prescription: updated };
};

// ─────────────────────────────────────────────────────────────
// STORY 16 — Generate Printable Prescription
// ─────────────────────────────────────────────────────────────

/**
 * Generates a printable HTML string for a given prescription.
 * The HTML includes medication details, instructions, pharmacy info,
 * and a doctor signature field.
 *
 * @param {string} id - Prescription ID
 * @returns {{ success: boolean, html?: string, error?: string }}
 */
const generatePrintablePrescription = (id) => {
  const rx = Prescription.findById(id);

  if (!rx) {
    return { success: false, error: "Prescription not found." };
  }

  // Format instructions section — show a warning if not yet added
  const instructionsBlock = rx.instructions
    ? `
      <tr><td><strong>Dosage:</strong></td><td>${rx.instructions.dosage}</td></tr>
      <tr><td><strong>Frequency:</strong></td><td>${rx.instructions.frequency}</td></tr>
      <tr><td><strong>Duration:</strong></td><td>${rx.instructions.duration}</td></tr>
      <tr><td><strong>Notes:</strong></td><td>${rx.instructions.notes || "None"}</td></tr>
    `
    : `<tr><td colspan="2" style="color:red;">⚠ No instructions added yet.</td></tr>`;

  // Build the full printable HTML document
  const html = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Prescription ${rx.id}</title>
  <style>
    /* Simple print-friendly styling */
    body {
      font-family: Arial, sans-serif;
      font-size: 14px;
      margin: 40px;
      color: #222;
    }
    .header {
      text-align: center;
      border-bottom: 2px solid #333;
      padding-bottom: 12px;
      margin-bottom: 20px;
    }
    .header h1 { margin: 0; font-size: 22px; }
    .header p  { margin: 2px 0; font-size: 13px; color: #555; }
    .section-title {
      background: #f0f0f0;
      padding: 6px 10px;
      font-weight: bold;
      margin-top: 20px;
      border-left: 4px solid #333;
    }
    table { width: 100%; border-collapse: collapse; margin-top: 8px; }
    td    { padding: 6px 8px; vertical-align: top; }
    td:first-child { width: 160px; color: #555; }
    .signature-box {
      margin-top: 40px;
      border-top: 1px solid #333;
      width: 280px;
      padding-top: 6px;
      font-size: 13px;
      color: #444;
    }
    .footer {
      margin-top: 40px;
      border-top: 1px solid #ccc;
      padding-top: 10px;
      font-size: 11px;
      color: #888;
      text-align: center;
    }
    @media print {
      body { margin: 20px; }
    }
  </style>
</head>
<body>

  <!-- Clinic / Header -->
  <div class="header">
    <h1>${rx.clinicName}</h1>
    <p>${rx.clinicAddress}</p>
    <p>Phone: ${rx.clinicPhone}</p>
  </div>

  <!-- Patient Information -->
  <div class="section-title">Patient Information</div>
  <table>
    <tr><td><strong>Name:</strong></td><td>${rx.patientName}</td></tr>
    <tr><td><strong>Date of Birth:</strong></td><td>${rx.patientDOB}</td></tr>
  </table>

  <!-- Prescription Details -->
  <div class="section-title">Prescription Details</div>
  <table>
    <tr><td><strong>Prescription ID:</strong></td><td>${rx.id}</td></tr>
    <tr><td><strong>Date Issued:</strong></td><td>${new Date(rx.createdAt).toLocaleDateString()}</td></tr>
    <tr><td><strong>Medication:</strong></td><td>${rx.medication}</td></tr>
    ${instructionsBlock}
  </table>

  <!-- Pharmacy Information -->
  <div class="section-title">Pharmacy Information</div>
  <table>
    <tr><td><strong>Pharmacy:</strong></td><td>${rx.pharmacyName}</td></tr>
    <tr><td><strong>Address:</strong></td><td>${rx.pharmacyAddress}</td></tr>
    <tr><td><strong>Phone:</strong></td><td>${rx.pharmacyPhone}</td></tr>
  </table>

  <!-- Doctor Signature -->
  <div class="section-title">Prescribing Doctor</div>
  <table>
    <tr><td><strong>Name:</strong></td><td>${rx.doctorName}</td></tr>
    <tr><td><strong>License No.:</strong></td><td>${rx.doctorLicense}</td></tr>
  </table>

  <div class="signature-box">
    Signature: ___________________________
    <br/>
    Date: _________________________________
  </div>

  <div class="footer">
    This prescription was generated electronically by the Pharmacy Prescription Integration System.
    Printed on: ${new Date().toLocaleString()}
  </div>

</body>
</html>
  `.trim();

  return { success: true, html };
};

// ─────────────────────────────────────────────────────────────
// STORY 19 — Track Prescription History
// ─────────────────────────────────────────────────────────────

/**
 * Retrieves the full status history (timeline) for a prescription.
 * Each entry includes a status, message, and timestamp.
 *
 * @param {string} id - Prescription ID
 * @returns {{ success: boolean, history?: array, error?: string }}
 */
const getPrescriptionHistory = (id) => {
  const prescription = Prescription.findById(id);

  if (!prescription) {
    return { success: false, error: "Prescription not found." };
  }

  // Return history sorted oldest → newest (chronological timeline)
  const sortedHistory = [...prescription.statusHistory].sort(
    (a, b) => new Date(a.timestamp) - new Date(b.timestamp)
  );

  return {
    success: true,
    prescriptionId: prescription.id,
    patientName: prescription.patientName,
    medication: prescription.medication,
    currentStatus: prescription.status,
    totalEvents: sortedHistory.length,
    history: sortedHistory,
  };
};

module.exports = {
  addInstructions,
  generatePrintablePrescription,
  getPrescriptionHistory,
};
