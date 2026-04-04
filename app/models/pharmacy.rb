# app/models/pharmacy.rb
# Epic 1 — Pharmacy Discovery & Selection
class Pharmacy < ApplicationRecord
  PHARMACY_TYPES = %w[retail mail_order specialty compounding].freeze

  validates :name,         presence: true
  validates :identifier,   presence: true, uniqueness: true
  validates :address,      presence: true
  validates :zip,          presence: true
  validates :pharmacy_type, inclusion: { in: PHARMACY_TYPES }

  # Epic 1: Find pharmacies by ZIP code (radius search placeholder)
  scope :by_zip, ->(zip) { where(zip: zip) }
  scope :e_rx_capable, -> { where(supports_e_rx: true) }

  # Simple ZIP-based search — lat/lon radius can be wired in for production
  def self.search_by_zip(zip, _radius_km = 10)
    where(zip: zip).order(:name)
  end

  def accepts_e_prescriptions?
    supports_e_rx?
  end
end
