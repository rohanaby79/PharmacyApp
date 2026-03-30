/**
 * app.js — Entry Point
 * Sets up the Express server and registers all routes.
 *
 * Pharmacy Prescription Integration System
 * University Software Engineering Project
 */

const express = require("express");
const app = express();
const PORT = 3000;

// ── Middleware ──────────────────────────────────────────────
// Parse incoming JSON request bodies
app.use(express.json());

// ── Routes ──────────────────────────────────────────────────
const prescriptionRoutes = require("./routes/prescriptionRoutes");

// All prescription-related endpoints are prefixed with /prescriptions
app.use("/prescriptions", prescriptionRoutes);

// ── Homepage Dashboard ────────────────────────────────────────
// Renders a styled HTML landing page instead of raw JSON
app.get("/", (req, res) => {
  res.setHeader("Content-Type", "text/html");
  res.send(`
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Pharmacy Prescription System</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Inter', Arial, sans-serif; background: #f0f4f8; min-height: 100vh; padding: 40px 20px; color: #1a1a2e; }
    .page { max-width: 780px; margin: 0 auto; }

    /* Hero */
    .hero { background: #1a3c5e; border-radius: 16px; padding: 40px 40px 36px; margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; }
    .hero-left h1 { font-size: 26px; font-weight: 700; color: #fff; letter-spacing: -0.4px; }
    .hero-left p { font-size: 13px; color: rgba(255,255,255,0.6); margin-top: 6px; line-height: 1.6; }
    .hero-badge { background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.2); border-radius: 12px; padding: 14px 22px; text-align: center; }
    .hero-badge .rx { font-size: 34px; font-weight: 700; color: #fff; font-style: italic; line-height: 1; }
    .hero-badge .sub { font-size: 10px; color: rgba(255,255,255,0.55); letter-spacing: 1.5px; margin-top: 3px; }

    /* Status pill */
    .status-pill { display: inline-flex; align-items: center; gap: 6px; background: #dcfce7; border: 1px solid #86efac; border-radius: 20px; padding: 5px 14px; font-size: 11px; font-weight: 600; color: #166534; margin-top: 14px; }
    .status-dot { width: 7px; height: 7px; border-radius: 50%; background: #16a34a; }

    /* Section title */
    .section-title { font-size: 11px; font-weight: 600; color: #6b7fa3; text-transform: uppercase; letter-spacing: 0.8px; margin-bottom: 12px; }

    /* Endpoint cards */
    .endpoints { display: flex; flex-direction: column; gap: 12px; margin-bottom: 24px; }
    .endpoint-card { background: #fff; border: 0.5px solid #dde8f7; border-radius: 12px; padding: 16px 20px; display: flex; align-items: center; gap: 16px; text-decoration: none; transition: border-color 0.15s; }
    .endpoint-card:hover { border-color: #2563a8; }
    .method { font-size: 10px; font-weight: 700; padding: 4px 10px; border-radius: 6px; letter-spacing: 0.5px; flex-shrink: 0; }
    .method.get { background: #dcfce7; color: #166534; }
    .method.post { background: #fff7ed; color: #9a3412; }
    .endpoint-info { flex: 1; }
    .endpoint-path { font-size: 13px; font-weight: 600; color: #1a1a2e; font-family: monospace; }
    .endpoint-desc { font-size: 11px; color: #6b7fa3; margin-top: 2px; }
    .endpoint-arrow { font-size: 16px; color: #c0cfe8; }

    /* Seed cards */
    .seed-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 24px; }
    .seed-card { background: #fff; border: 0.5px solid #dde8f7; border-radius: 12px; padding: 16px 20px; }
    .seed-id { font-size: 18px; font-weight: 700; color: #1a3c5e; font-style: italic; margin-bottom: 8px; }
    .seed-field { font-size: 11px; color: #6b7fa3; margin-bottom: 2px; }
    .seed-val { font-size: 13px; font-weight: 500; color: #1a1a2e; margin-bottom: 6px; }
    .seed-links { display: flex; gap: 8px; margin-top: 10px; padding-top: 10px; border-top: 0.5px solid #eef2f9; }
    .seed-link { font-size: 10px; font-weight: 600; color: #2563a8; text-decoration: none; background: #eef4ff; border-radius: 6px; padding: 3px 10px; }
    .seed-link:hover { background: #dbeafe; }

    /* Footer */
    .footer { text-align: center; font-size: 10px; color: #a0aec0; margin-top: 8px; }
  </style>
</head>
<body>
<div class="page">

  <!-- Hero -->
  <div class="hero">
    <div class="hero-left">
      <h1>Pharmacy Prescription<br/>Integration System</h1>
      <p>University Software Engineering Project<br/>Node.js · Express.js · MVC Architecture</p>
      <div class="status-pill"><div class="status-dot"></div> Server is running</div>
    </div>
    <div class="hero-badge">
      <div class="rx">Rx</div>
      <div class="sub">API v1.0</div>
    </div>
  </div>

  <!-- Endpoints -->
  <div class="section-title">Available Endpoints</div>
  <div class="endpoints">
    <div class="endpoint-card">
      <span class="method post">POST</span>
      <div class="endpoint-info">
        <div class="endpoint-path">/prescriptions/:id/instructions</div>
        <div class="endpoint-desc">Story 6 — Add medication dosage instructions to a prescription</div>
      </div>
      <span class="endpoint-arrow">›</span>
    </div>
    <a class="endpoint-card" href="/prescriptions/RX-001/print">
      <span class="method get">GET</span>
      <div class="endpoint-info">
        <div class="endpoint-path">/prescriptions/:id/print</div>
        <div class="endpoint-desc">Story 16 — Generate a printable HTML prescription document</div>
      </div>
      <span class="endpoint-arrow">›</span>
    </a>
    <a class="endpoint-card" href="/prescriptions/RX-001/history">
      <span class="method get">GET</span>
      <div class="endpoint-info">
        <div class="endpoint-path">/prescriptions/:id/history</div>
        <div class="endpoint-desc">Story 19 — View the full status timeline for a prescription</div>
      </div>
      <span class="endpoint-arrow">›</span>
    </a>
  </div>

  <!-- Seed prescriptions -->
  <div class="section-title">Seed Prescriptions</div>
  <div class="seed-grid">
    <div class="seed-card">
      <div class="seed-id">Rx RX-001</div>
      <div class="seed-field">Patient</div>
      <div class="seed-val">John Smith</div>
      <div class="seed-field">Medication</div>
      <div class="seed-val">Amoxicillin</div>
      <div class="seed-field">Status</div>
      <div class="seed-val">Pending</div>
      <div class="seed-links">
        <a class="seed-link" href="/prescriptions/RX-001/print">Print</a>
        <a class="seed-link" href="/prescriptions/RX-001/history">History</a>
      </div>
    </div>
    <div class="seed-card">
      <div class="seed-id">Rx RX-002</div>
      <div class="seed-field">Patient</div>
      <div class="seed-val">Maria Gonzalez</div>
      <div class="seed-field">Medication</div>
      <div class="seed-val">Metformin</div>
      <div class="seed-field">Status</div>
      <div class="seed-val">Sent to Pharmacy</div>
      <div class="seed-links">
        <a class="seed-link" href="/prescriptions/RX-002/print">Print</a>
        <a class="seed-link" href="/prescriptions/RX-002/history">History</a>
      </div>
    </div>
  </div>

  <div class="footer">Pharmacy Prescription Integration System &nbsp;·&nbsp; CSC 411 Senior Project &nbsp;·&nbsp; ${new Date().getFullYear()}</div>
</div>
</body>
</html>
  `);
});

// ── 404 Handler ──────────────────────────────────────────────
// Catch-all for any route that doesn't exist
app.use((req, res) => {
  res.status(404).json({ success: false, message: "Route not found." });
});

// ── Start Server ─────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`\n✅ Server is running at http://localhost:${PORT}`);
  console.log(`   Seed prescriptions available: RX-001, RX-002\n`);
});

module.exports = app;
