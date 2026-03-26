/**
 * Prescription Model
 * Defines the structure of a prescription and manages in-memory storage.
 * No database required — data is stored in a simple array.
 */

// In-memory "database" — resets every time the server restarts
const prescriptions = [
  // Seed data so we can test without creating prescriptions first
  {
    id: "RX-001",
    patientName: "John Smith",
    patientDOB: "1985-04-12",
    doctorName: "Dr. Sarah Connor",
    doctorLicense: "MD-78432",
    clinicName: "Sunrise Medical Clinic",
    clinicAddress: "123 Health Ave, Tulsa, OK 74101",
    clinicPhone: "(918) 555-0100",
    pharmacyName: "CityMed Pharmacy",
    pharmacyAddress: "456 Wellness Blvd, Tulsa, OK 74102",
    pharmacyPhone: "(918) 555-0199",
    medication: "Amoxicillin",
    status: "pending",
    instructions: null,   // populated by Story 6
    statusHistory: [      // used by Story 19
      {
        status: "pending",
        message: "Prescription created.",
        timestamp: new Date("2025-01-10T09:00:00").toISOString(),
      },
    ],
    createdAt: new Date("2025-01-10T09:00:00").toISOString(),
  },
  {
    id: "RX-002",
    patientName: "Maria Gonzalez",
    patientDOB: "1990-08-22",
    doctorName: "Dr. Sarah Connor",
    doctorLicense: "MD-78432",
    clinicName: "Sunrise Medical Clinic",
    clinicAddress: "123 Health Ave, Tulsa, OK 74101",
    clinicPhone: "(918) 555-0100",
    pharmacyName: "QuickFill Drugs",
    pharmacyAddress: "789 Pharmacy Lane, Tulsa, OK 74103",
    pharmacyPhone: "(918) 555-0250",
    medication: "Metformin",
    status: "sent_to_pharmacy",
    instructions: {
      dosage: "500mg",
      frequency: "Twice daily",
      duration: "30 days",
      notes: "Take with meals to reduce stomach upset.",
      addedAt: new Date("2025-01-11T10:30:00").toISOString(),
    },
    statusHistory: [
      {
        status: "pending",
        message: "Prescription created.",
        timestamp: new Date("2025-01-11T09:00:00").toISOString(),
      },
      {
        status: "sent_to_pharmacy",
        message: "Prescription sent electronically to QuickFill Drugs.",
        timestamp: new Date("2025-01-11T09:45:00").toISOString(),
      },
    ],
    createdAt: new Date("2025-01-11T09:00:00").toISOString(),
  },
];

/**
 * Returns all prescriptions (useful for debugging/admin).
 */
const findAll = () => prescriptions;

/**
 * Finds a single prescription by its ID.
 * Returns undefined if not found.
 */
const findById = (id) => prescriptions.find((rx) => rx.id === id);

/**
 * Updates a prescription object in-place.
 * We find the index and replace the entry so changes are reflected globally.
 */
const update = (id, updatedData) => {
  const index = prescriptions.findIndex((rx) => rx.id === id);
  if (index === -1) return null;

  // Merge existing prescription with new data
  prescriptions[index] = { ...prescriptions[index], ...updatedData };
  return prescriptions[index];
};

module.exports = { findAll, findById, update };
