/**
 * Prescription Routes
 * Maps HTTP endpoints to their controller functions.
 * This file only defines routes — no logic lives here.
 *
 * Endpoints:
 *   POST /prescriptions/:id/instructions  → Story 6
 *   GET  /prescriptions/:id/print         → Story 16
 *   GET  /prescriptions/:id/history       → Story 19
 */

const express = require("express");
const router = express.Router();

const prescriptionController = require("../controllers/prescriptionController");

// Story 6 — Add medication instructions to a prescription
router.post("/:id/instructions", prescriptionController.addInstructions);

// Story 16 — Get a printable HTML version of the prescription
router.get("/:id/print", prescriptionController.printPrescription);

// Story 19 — Get the status history / timeline of a prescription
router.get("/:id/history", prescriptionController.getPrescriptionHistory);

module.exports = router;
