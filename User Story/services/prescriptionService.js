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

  // Add a timeline event so history reflects this update
  const newHistoryEntry = {
    status: 'instructions_added',
    message: `Instructions added: ${dosage}, ${frequency} for ${duration}.`,
    timestamp: new Date().toISOString(),
  };
  const updatedHistory = [...prescription.statusHistory, newHistoryEntry];

  // Save both instructions and the new history entry
  const updated = Prescription.update(id, { instructions, statusHistory: updatedHistory });

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

  // Build the full printable HTML document
  const html = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Prescription ${rx.id}</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: 'Inter', Arial, sans-serif;
      background: #f4f6f9;
      color: #1a1a2e;
      min-height: 100vh;
      padding: 40px 20px;
    }

    .page {
      max-width: 780px;
      margin: 0 auto;
      background: #ffffff;
      border-radius: 16px;
      box-shadow: 0 4px 24px rgba(0,0,0,0.10);
      overflow: hidden;
    }

    /* ── Header Banner ── */
    .header {
      background: linear-gradient(135deg, #1a3c5e 0%, #2563a8 100%);
      padding: 32px 40px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .header-left h1 {
      font-size: 22px;
      font-weight: 700;
      color: #ffffff;
      letter-spacing: -0.3px;
    }
    .header-left p {
      font-size: 12px;
      color: rgba(255,255,255,0.75);
      margin-top: 4px;
      line-height: 1.6;
    }
    .rx-badge {
      background: rgba(255,255,255,0.15);
      border: 1px solid rgba(255,255,255,0.3);
      border-radius: 10px;
      padding: 10px 18px;
      text-align: center;
    }
    .rx-badge .rx-symbol {
      font-size: 28px;
      font-weight: 700;
      color: #ffffff;
      font-style: italic;
      line-height: 1;
    }
    .rx-badge .rx-id {
      font-size: 11px;
      color: rgba(255,255,255,0.7);
      margin-top: 2px;
      letter-spacing: 1px;
    }

    /* ── Status Bar ── */
    .status-bar {
      background: #eef4ff;
      border-bottom: 1px solid #d0e3ff;
      padding: 10px 40px;
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 12px;
      color: #2563a8;
    }
    .status-dot {
      width: 8px; height: 8px;
      border-radius: 50%;
      background: #2563a8;
    }

    /* ── Body ── */
    .body { padding: 32px 40px; }

    /* ── Two-column grid ── */
    .grid-2 {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 20px;
      margin-bottom: 24px;
    }

    /* ── Section cards ── */
    .card {
      background: #f8faff;
      border: 1px solid #e2eaf7;
      border-radius: 12px;
      overflow: hidden;
    }
    .card-full { grid-column: 1 / -1; }

    .card-header {
      background: #1a3c5e;
      padding: 10px 16px;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .card-header .icon {
      width: 18px; height: 18px;
      background: rgba(255,255,255,0.2);
      border-radius: 4px;
      display: flex; align-items: center; justify-content: center;
      font-size: 10px;
      color: white;
      flex-shrink: 0;
    }
    .card-header h3 {
      font-size: 11px;
      font-weight: 600;
      color: #ffffff;
      text-transform: uppercase;
      letter-spacing: 0.8px;
    }

    .card-body { padding: 14px 16px; }

    /* ── Field rows ── */
    .field { margin-bottom: 10px; }
    .field:last-child { margin-bottom: 0; }
    .field-label {
      font-size: 10px;
      font-weight: 600;
      color: #6b7fa3;
      text-transform: uppercase;
      letter-spacing: 0.6px;
      margin-bottom: 2px;
    }
    .field-value {
      font-size: 14px;
      font-weight: 500;
      color: #1a1a2e;
    }

    /* ── Medication highlight ── */
    .med-name {
      font-size: 20px;
      font-weight: 700;
      color: #1a3c5e;
      margin-bottom: 14px;
      padding-bottom: 12px;
      border-bottom: 1px solid #e2eaf7;
    }

    .instruction-pills {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      margin-bottom: 12px;
    }
    .pill {
      background: #e8f0fe;
      border: 1px solid #c5d8fc;
      border-radius: 20px;
      padding: 4px 12px;
      font-size: 12px;
      font-weight: 500;
      color: #1a3c5e;
    }
    .pill span {
      color: #6b7fa3;
      font-weight: 400;
      margin-right: 4px;
    }

    .notes-box {
      background: #fffbeb;
      border: 1px solid #fde68a;
      border-radius: 8px;
      padding: 10px 12px;
      font-size: 12px;
      color: #78350f;
      line-height: 1.5;
    }
    .notes-box strong { display: block; margin-bottom: 2px; font-size: 10px; text-transform: uppercase; letter-spacing: 0.5px; color: #92400e; }

    .no-instructions {
      background: #fff5f5;
      border: 1px solid #fecaca;
      border-radius: 8px;
      padding: 10px 12px;
      font-size: 12px;
      color: #b91c1c;
    }

    /* ── Signature section ── */
    .signature-section {
      margin-top: 28px;
      padding-top: 24px;
      border-top: 1px dashed #d0e3ff;
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 24px;
    }
    .sig-block { }
    .sig-label {
      font-size: 10px;
      font-weight: 600;
      color: #6b7fa3;
      text-transform: uppercase;
      letter-spacing: 0.6px;
      margin-bottom: 28px;
    }
    .sig-line {
      border-bottom: 1.5px solid #1a3c5e;
      margin-bottom: 6px;
    }
    .sig-caption {
      font-size: 11px;
      color: #6b7fa3;
    }

    /* ── Footer ── */
    .footer {
      background: #f0f4fb;
      border-top: 1px solid #e2eaf7;
      padding: 14px 40px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .footer p { font-size: 10px; color: #8899b8; }
    .footer .valid-stamp {
      background: #dcfce7;
      border: 1px solid #86efac;
      border-radius: 6px;
      padding: 4px 10px;
      font-size: 10px;
      font-weight: 600;
      color: #166534;
    }

    @media print {
      body { background: white; padding: 0; }
      .page { box-shadow: none; border-radius: 0; }
    }
  </style>
</head>
<body>
<div class="page">

  <!-- Header -->
  <div class="header">
    <div class="header-left">
      <h1>${rx.clinicName}</h1>
      <p>${rx.clinicAddress}<br/>${rx.clinicPhone}</p>
    </div>
    <div class="rx-badge">
      <div class="rx-symbol">Rx</div>
      <div class="rx-id">${rx.id}</div>
    </div>
  </div>

  <!-- Status Bar -->
  <div class="status-bar">
    <div class="status-dot"></div>
    Status: <strong>${rx.status.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase())}</strong>
    &nbsp;·&nbsp; Issued: ${new Date(rx.createdAt).toLocaleDateString('en-US', { year:'numeric', month:'long', day:'numeric' })}
  </div>

  <!-- Body -->
  <div class="body">
    <div class="grid-2">

      <!-- Patient Card -->
      <div class="card">
        <div class="card-header">
          <div class="icon">P</div>
          <h3>Patient Information</h3>
        </div>
        <div class="card-body">
          <div class="field">
            <div class="field-label">Full Name</div>
            <div class="field-value">${rx.patientName}</div>
          </div>
          <div class="field">
            <div class="field-label">Date of Birth</div>
            <div class="field-value">${rx.patientDOB}</div>
          </div>
        </div>
      </div>

      <!-- Doctor Card -->
      <div class="card">
        <div class="card-header">
          <div class="icon">D</div>
          <h3>Prescribing Doctor</h3>
        </div>
        <div class="card-body">
          <div class="field">
            <div class="field-label">Doctor Name</div>
            <div class="field-value">${rx.doctorName}</div>
          </div>
          <div class="field">
            <div class="field-label">License Number</div>
            <div class="field-value">${rx.doctorLicense}</div>
          </div>
        </div>
      </div>

      <!-- Medication Card -->
      <div class="card card-full">
        <div class="card-header">
          <div class="icon">M</div>
          <h3>Medication &amp; Instructions</h3>
        </div>
        <div class="card-body">
          <div class="med-name">${rx.medication}</div>
          ${rx.instructions ? `
          <div class="instruction-pills">
            <div class="pill"><span>Dosage</span>${rx.instructions.dosage}</div>
            <div class="pill"><span>Frequency</span>${rx.instructions.frequency}</div>
            <div class="pill"><span>Duration</span>${rx.instructions.duration}</div>
          </div>
          ${rx.instructions.notes ? `<div class="notes-box"><strong>Additional Notes</strong>${rx.instructions.notes}</div>` : ''}
          ` : `<div class="no-instructions">&#9888; No medication instructions have been added to this prescription yet.</div>`}
        </div>
      </div>

      <!-- Pharmacy Card -->
      <div class="card card-full">
        <div class="card-header">
          <div class="icon">Ph</div>
          <h3>Pharmacy Information</h3>
        </div>
        <div class="card-body" style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px;">
          <div class="field">
            <div class="field-label">Pharmacy Name</div>
            <div class="field-value">${rx.pharmacyName}</div>
          </div>
          <div class="field">
            <div class="field-label">Address</div>
            <div class="field-value">${rx.pharmacyAddress}</div>
          </div>
          <div class="field">
            <div class="field-label">Phone</div>
            <div class="field-value">${rx.pharmacyPhone}</div>
          </div>
        </div>
      </div>

    </div>

    <!-- Signature Section -->
    <div class="signature-section">
      <div class="sig-block">
        <div class="sig-label">Doctor Signature</div>
        <div class="sig-line"></div>
        <div class="sig-caption">${rx.doctorName} &nbsp;·&nbsp; ${rx.doctorLicense}</div>
      </div>
      <div class="sig-block">
        <div class="sig-label">Date Signed</div>
        <div class="sig-line"></div>
        <div class="sig-caption">MM / DD / YYYY</div>
      </div>
    </div>
  </div>

  <!-- Footer -->
  <div class="footer">
    <p>Generated by Pharmacy Prescription Integration System &nbsp;·&nbsp; ${new Date().toLocaleString()}</p>
    <div class="valid-stamp">&#10003; Valid Prescription</div>
  </div>

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

  // Sort history oldest → newest (chronological timeline)
  const sortedHistory = [...prescription.statusHistory].sort(
    (a, b) => new Date(a.timestamp) - new Date(b.timestamp)
  );

  // Status color mapping for the timeline badges
  const statusColors = {
    pending:              { bg: "#fef9c3", border: "#fde047", text: "#713f12", dot: "#ca8a04" },
    instructions_added:   { bg: "#f0fdf4", border: "#86efac", text: "#14532d", dot: "#16a34a" },
    sent_to_pharmacy:  { bg: "#dbeafe", border: "#93c5fd", text: "#1e3a5f", dot: "#2563eb" },
    filled:            { bg: "#dcfce7", border: "#86efac", text: "#14532d", dot: "#16a34a" },
    dispensed:         { bg: "#f3e8ff", border: "#d8b4fe", text: "#3b0764", dot: "#9333ea" },
    cancelled:         { bg: "#fee2e2", border: "#fca5a5", text: "#7f1d1d", dot: "#dc2626" },
  };

  // Build a timeline item for each history entry
  const timelineItems = sortedHistory.map((entry, index) => {
    const colors = statusColors[entry.status] || statusColors.pending;
    const isLast = index === sortedHistory.length - 1;
    const date = new Date(entry.timestamp);
    const formattedDate = date.toLocaleDateString("en-US", { year: "numeric", month: "long", day: "numeric" });
    const formattedTime = date.toLocaleTimeString("en-US", { hour: "2-digit", minute: "2-digit" });
    const label = entry.status.replace(/_/g, " ").replace(/\b\w/g, c => c.toUpperCase());

    return `
      <div style="display:flex;gap:16px;margin-bottom:${isLast ? "0" : "8px"};">
        <!-- Dot + line -->
        <div style="display:flex;flex-direction:column;align-items:center;width:20px;flex-shrink:0;">
          <div style="width:14px;height:14px;border-radius:50%;background:${colors.dot};border:2px solid white;box-shadow:0 0 0 2px ${colors.dot};margin-top:14px;flex-shrink:0;"></div>
          ${!isLast ? `<div style="width:2px;flex:1;background:#e2e8f0;margin-top:4px;"></div>` : ""}
        </div>
        <!-- Card -->
        <div style="flex:1;background:${colors.bg};border:1px solid ${colors.border};border-radius:10px;padding:12px 16px;margin-bottom:${isLast ? "0" : "8px"};">
          <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:8px;">
            <span style="font-size:13px;font-weight:600;color:${colors.text};">${label}</span>
            <span style="font-size:10px;color:${colors.text};opacity:0.75;white-space:nowrap;">${formattedDate} · ${formattedTime}</span>
          </div>
          <p style="font-size:12px;color:${colors.text};opacity:0.85;margin-top:4px;line-height:1.5;">${entry.message}</p>
        </div>
      </div>
    `;
  }).join("");

  const currentColors = statusColors[prescription.status] || statusColors.pending;
  const currentLabel = prescription.status.replace(/_/g, " ").replace(/\b\w/g, c => c.toUpperCase());

  const html = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>History — ${prescription.id}</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Inter', Arial, sans-serif; background: #f0f4f8; min-height: 100vh; padding: 40px 20px; color: #1a1a2e; }
    .page { max-width: 680px; margin: 0 auto; }
    @media print { body { background: white; padding: 0; } }
  </style>
</head>
<body>
<div class="page">

  <!-- Header -->
  <div style="background:#1a3c5e;border-radius:16px 16px 0 0;padding:28px 32px;display:flex;justify-content:space-between;align-items:center;">
    <div>
      <p style="font-size:11px;color:rgba(255,255,255,0.55);text-transform:uppercase;letter-spacing:1px;margin-bottom:4px;">Prescription History</p>
      <h1 style="font-size:22px;font-weight:700;color:#fff;letter-spacing:-0.3px;">${prescription.patientName}</h1>
      <p style="font-size:12px;color:rgba(255,255,255,0.65);margin-top:4px;">${prescription.medication} &nbsp;·&nbsp; ${prescription.id}</p>
    </div>
    <div style="background:rgba(255,255,255,0.12);border:1px solid rgba(255,255,255,0.22);border-radius:10px;padding:10px 18px;text-align:center;">
      <div style="font-size:26px;font-weight:700;color:#fff;font-style:italic;line-height:1;">Rx</div>
      <div style="font-size:10px;color:rgba(255,255,255,0.6);margin-top:2px;letter-spacing:1px;">${prescription.id}</div>
    </div>
  </div>

  <!-- Summary bar -->
  <div style="background:#eef4ff;border-left:1px solid #d0e3ff;border-right:1px solid #d0e3ff;padding:10px 32px;display:flex;align-items:center;gap:24px;">
    <div style="display:flex;align-items:center;gap:6px;">
      <div style="width:8px;height:8px;border-radius:50%;background:${currentColors.dot};"></div>
      <span style="font-size:11px;color:#1a3c5e;">Current status: <strong>${currentLabel}</strong></span>
    </div>
    <span style="font-size:11px;color:#6b7fa3;">${sortedHistory.length} event${sortedHistory.length !== 1 ? "s" : ""} recorded</span>
  </div>

  <!-- Timeline body -->
  <div style="background:#fff;border-radius:0 0 16px 16px;border:1px solid #e2eaf7;border-top:none;padding:28px 32px;">
    <p style="font-size:11px;font-weight:600;color:#6b7fa3;text-transform:uppercase;letter-spacing:0.8px;margin-bottom:20px;">Timeline</p>
    ${timelineItems}
  </div>

  <!-- Footer -->
  <div style="text-align:center;margin-top:16px;">
    <p style="font-size:10px;color:#a0aec0;">Generated by Pharmacy Prescription Integration System &nbsp;·&nbsp; ${new Date().toLocaleString()}</p>
  </div>

</div>
</body>
</html>
  `.trim();

  return { success: true, html };
};

module.exports = {
  addInstructions,
  generatePrintablePrescription,
  getPrescriptionHistory,
};
