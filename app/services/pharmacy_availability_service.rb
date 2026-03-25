class PharmacyAvailabilityService
  def initialize(pharmacy_id)
    @pharmacy_id = pharmacy_id
  end

  def check_availability
    pharmacy = find_pharmacy(@pharmacy_id)
    return { supported: false, message: "Pharmacy not found." } if pharmacy.nil?

    unless pharmacy[:supports_e_rx]
      return { supported: false, message: "#{pharmacy[:name]} does not support electronic prescription transmission. Please choose an alternate method." }
    end

    { supported: true, message: "#{pharmacy[:name]} supports electronic prescriptions.", pharmacy: pharmacy }
  end

  private

  def find_pharmacy(id)
    pharmacies_data.find { |p| p[:identifier].to_s == id.to_s }
  end

  def pharmacies_data
    file_path = Rails.root.join("data", "pharmacies.json")
    return [] unless File.exist?(file_path)
    JSON.parse(File.read(file_path), symbolize_names: true)
  rescue JSON::ParserError
    []
  end
end
