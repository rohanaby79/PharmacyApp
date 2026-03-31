class TransmissionLog < ApplicationRecord
    # Associate doctors with pharmacies
    belongs_to :doctor, optional: true
  
    # Verify the required fields
    validates :action, presence: true
    validates :status, presence: true
  
    # Record an audit log (Core Method)
    def self.log(doctor_id:, pharmacy_id:, prescription_id:, action:, status:, ip_address:)
      create!(
        doctor_id:       doctor_id,
        pharmacy_id:     pharmacy_id,
        prescription_id: prescription_id,
        action:          action,
        status:          status,
        ip_address:      ip_address
      )
    end
  end