class Prescription

  STORE = [
    {
      id: "RX-001",
      patient_name: "John Smith",
      patient_dob: "1985-04-12",
      doctor_name: "Dr. Sarah Connor",
      doctor_license: "MD-78432",
      clinic_name: "Sunrise Medical Clinic",
      clinic_address: "123 Health Ave, Tulsa, OK 74101",
      clinic_phone: "(918) 555-0100",
      pharmacy_name: "CityMed Pharmacy",
      pharmacy_address: "456 Wellness Blvd, Tulsa, OK 74102",
      pharmacy_phone: "(918) 555-0199",
      medication: "Amoxicillin",
      status: "pending",
      instructions: nil,
      status_history: [
        { status: "pending", message: "Prescription created.", timestamp: "2025-01-10T09:00:00Z" }
      ],
      created_at: "2025-01-10T09:00:00Z"
    },
    {
      id: "RX-002",
      patient_name: "Maria Gonzalez",
      patient_dob: "1990-08-22",
      doctor_name: "Dr. Sarah Connor",
      doctor_license: "MD-78432",
      clinic_name: "Sunrise Medical Clinic",
      clinic_address: "123 Health Ave, Tulsa, OK 74101",
      clinic_phone: "(918) 555-0100",
      pharmacy_name: "QuickFill Drugs",
      pharmacy_address: "789 Pharmacy Lane, Tulsa, OK 74103",
      pharmacy_phone: "(918) 555-0250",
      medication: "Metformin",
      status: "sent_to_pharmacy",
      instructions: {
        dosage: "500mg",
        frequency: "Twice daily",
        duration: "30 days",
        notes: "Take with meals to reduce stomach upset.",
        added_at: "2025-01-11T10:30:00Z"
      },
      status_history: [
        { status: "pending", message: "Prescription created.", timestamp: "2025-01-11T09:00:00Z" },
        { status: "sent_to_pharmacy", message: "Prescription sent electronically to QuickFill Drugs.", timestamp: "2025-01-11T09:45:00Z" }
      ],
      created_at: "2025-01-11T09:00:00Z"
    }
  ]

  def self.find_by_id(id)
    STORE.find { |rx| rx[:id] == id }
  end

  def self.update(id, new_data)
    rx = find_by_id(id)
    return nil unless rx
    rx.merge!(new_data)
    rx
  end

end