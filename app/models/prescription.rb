class Prescription < ApplicationRecord
  STATUSES = %w[Draft Sent Received Processing Ready Rejected Error].freeze

  validates :medication, presence: true
  validates :dosage, presence: true
  validates :frequency, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :patient_id, presence: true
  validates :provider_id, presence: true
  validates :pharmacy_id, presence: true
  validates :status, inclusion: { in: STATUSES }

  before_validation :set_default_status, on: :create

  private

  def set_default_status
    self.status ||= "Draft"
  end
end