# app/services/pharmacy_availability_service.rb
# Epic 1 — Validate that a pharmacy accepts e-Rx before transmission.
require "ostruct"
class PharmacyAvailabilityService
  def initialize(pharmacy_id)
    @pharmacy_id = pharmacy_id
  end

  def check_availability
    pharmacy = find_pharmacy(@pharmacy_id)
    return { supported: false, message: "Pharmacy '#{@pharmacy_id}' not found." } if pharmacy.nil?

    unless pharmacy_supports_e_rx?(pharmacy)
      name = pharmacy.respond_to?(:name) ? pharmacy[:name] || pharmacy.name : pharmacy.to_s
      return {
        supported: false,
        message:   "#{name} does not support electronic prescription transmission. Please use the manual export option."
      }
    end

    name = pharmacy.respond_to?(:name) ? pharmacy[:name] || pharmacy.name : pharmacy.to_s
    { supported: true, message: "#{name} supports electronic prescriptions.", pharmacy: pharmacy }
  end

  private

  def find_pharmacy(id)
    id_str = id.to_s

    # OSM pharmacies — not in DB, build a lightweight struct
    if id_str.start_with?("OSM-")
      return OpenStruct.new(name: "OSM Pharmacy (#{id_str})", supports_e_rx: true, pharmacy_type: "retail", identifier: id_str)
    end

    # Try by database primary key first (dashboard sends integer id)
    if id_str =~ /\A\d+\z/
      db_record = Pharmacy.find_by(id: id_str.to_i)
      return db_record if db_record
    end

    # Fall back to identifier string (e.g. "CVS001")
    db_record = Pharmacy.find_by(identifier: id_str)
    return db_record if db_record

    # JSON fallback for demo mode
    pharmacies_data.find { |p| p[:identifier].to_s == id_str }
  end

  def pharmacy_supports_e_rx?(pharmacy)
    pharmacy.respond_to?(:supports_e_rx) ? pharmacy.supports_e_rx : pharmacy[:supports_e_rx]
  end

  def pharmacies_data
    file_path = Rails.root.join("data", "pharmacies.json")
    return [] unless File.exist?(file_path)
    JSON.parse(File.read(file_path), symbolize_names: true)
  rescue JSON::ParserError
    []
  end
end
