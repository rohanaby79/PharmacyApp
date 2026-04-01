class PrescriptionInstruction < ApplicationRecord
  validates :prescription_id, presence: true
  validates :dosage,          presence: true
  validates :frequency,       presence: true
  validates :duration,        presence: true

  def self.for_doctor(doctor_id)
    where(doctor_id: doctor_id).order(created_at: :desc)
  end

  def self.for_prescription(prescription_id)
    where(prescription_id: prescription_id).order(created_at: :desc).first
  end
end
