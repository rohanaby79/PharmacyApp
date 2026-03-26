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

// ── Health Check ─────────────────────────────────────────────
// Simple GET / so we can confirm the server is running in Postman
app.get("/", (req, res) => {
  res.json({
    message: "Pharmacy Prescription Integration System — API is running.",
    availableEndpoints: [
      "POST /prescriptions/:id/instructions",
      "GET  /prescriptions/:id/print",
      "GET  /prescriptions/:id/history",
    ],
    seedPrescriptionIds: ["RX-001", "RX-002"],
  });
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
