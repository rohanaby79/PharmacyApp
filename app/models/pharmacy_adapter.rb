# app/models/pharmacy_adapter.rb
#
# PharmacyAdapter — Modular adapter layer (Epic 3).
# Routes a prescription to the correct pharmacy service based on the
# pharmacy record's `pharmacy_type` field (retail | mail_order).
# This makes it trivial to add future integrations (e.g. specialty, compounding)
# by registering a new service without touching existing code.
#
class PharmacyAdapter
  SERVICE_MAP = {
    "retail"     => :RetailPharmacyService,
    "mail_order" => :MailOrderPharmacyService
  }.freeze

  # Transmit a prescription to its pharmacy.
  # Returns a hash: { success: true/false, message: String, status: String }
  def self.dispatch(prescription)
    pharmacy = resolve_pharmacy(prescription.pharmacy_id)
    return { success: false, message: "Pharmacy '#{prescription.pharmacy_id}' not found.", status: "Error" } unless pharmacy

    unless pharmacy.supports_e_rx
      return { success: false, message: "#{pharmacy.name} does not support e-Rx. Use alternative export.", status: "Error" }
    end

    service_const = SERVICE_MAP[pharmacy.pharmacy_type&.downcase] || :RetailPharmacyService
    service_class = Object.const_get(service_const)
    service       = service_class.new(prescription, pharmacy)
    service.transmit
  rescue NameError => e
    { success: false, message: "Adapter service not found: #{e.message}", status: "Error" }
  rescue StandardError => e
    { success: false, message: "Transmission failed: #{e.message}", status: "Error" }
  end

  private

  def self.resolve_pharmacy(pharmacy_id)
    id_str = pharmacy_id.to_s

    # OSM pharmacies — not in DB, return a lightweight struct so transmission works
    if id_str.start_with?("OSM-")
      return OpenStruct.new(
        name:          "OSM Pharmacy (#{id_str})",
        identifier:    id_str,
        pharmacy_type: "retail",
        supports_e_rx: true
      )
    end

    # Try DB by primary key first (dashboard sends integer id)
    if id_str =~ /\A\d+\z/
      pharmacy = Pharmacy.find_by(id: id_str.to_i)
      return pharmacy if pharmacy
    end

    # Try DB by identifier string (e.g. "CVS001")
    pharmacy = Pharmacy.find_by(identifier: id_str)
    return pharmacy if pharmacy

    # JSON fallback (used in tests / before DB is seeded)
    file_path = Rails.root.join("data", "pharmacies.json")
    return nil unless File.exist?(file_path)
    data = JSON.parse(File.read(file_path), symbolize_names: true)
    record = data.find { |p| p[:identifier].to_s == pharmacy_id.to_s }
    return nil unless record

    # Build a lightweight OpenStruct so callers get the same interface
    OpenStruct.new(
      name:          record[:name],
      identifier:    record[:identifier],
      pharmacy_type: record.fetch(:pharmacy_type, "retail"),
      supports_e_rx: record[:supports_e_rx]
    )
  end
end
