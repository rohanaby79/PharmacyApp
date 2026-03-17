class Pharmacy < ApplicationRecord
  validates :name, :identifier, :address, :zip, presence: true

  # optional: simple distance check if using lat/lon (here just placeholder)
  def self.within_radius(zip, radius_km = 10)
    # For demo: return pharmacies matching zip
    where(zip: zip)
  end
end