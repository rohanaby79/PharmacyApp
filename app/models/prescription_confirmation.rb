class PrescriptionConfirmation < ApplicationRecord
    # Verify the required fields
    validates :prescription_id, presence: true
    validates :pharmacy_id, presence: true
    validates :status, presence: true
    validates :status, inclusion: {
      in: %w[received ready_for_pickup issue],
      message: "must be received, ready_for_pickup, or issue"
    }
  
    # Update the prescription status to "Received"
    def self.receive_confirmation(prescription_id:, pharmacy_id:, status:, message:)
      create!(
        prescription_id: prescription_id,
        pharmacy_id:     pharmacy_id,
        status:          status,
        message:         message,
        confirmed_at:    Time.current
      )
    end
  end