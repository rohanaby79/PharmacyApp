class PrescriptionExport < ApplicationRecord
    # Verify required fields
    validates :prescription_id, presence: true
    validates :doctor_id, presence: true
    validates :file_path, presence: true
    validates :file_format, presence: true
    validates :file_format, inclusion: {
      in: %w[json csv],
      message: "must be json or csv"
    }
  end