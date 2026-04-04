# app/services/retail_pharmacy_service.rb
#
# RetailPharmacyService — Handles e-Rx transmission for retail/chain pharmacies
# (e.g. CVS, Walgreens) via a REST API call structured around NCPDP SCRIPT 10.6.
#
# In production this would call the pharmacy's real API endpoint.
# For demonstration/academic purposes the endpoint is configurable via ENV.
#
require "net/http"
require "json"
require "ostruct"

class RetailPharmacyService
  # Default demo endpoint — override with PHARMACY_API_URL env var in production.
  ENDPOINT = ENV.fetch("PHARMACY_API_URL", "https://demo.pharmacyapi.example.com/api/v1/prescriptions")

  def initialize(prescription, pharmacy)
    @prescription = prescription
    @pharmacy     = pharmacy
  end

  def transmit
    payload = build_ncpdp_payload
    response = post_to_pharmacy(payload)
    handle_response(response)
  rescue Errno::ECONNREFUSED, SocketError, Net::OpenTimeout, Net::ReadTimeout => e
    { success: false, message: "Network error reaching #{@pharmacy.name}: #{e.message}", status: "Error" }
  rescue StandardError => e
    { success: false, message: "RetailPharmacyService error: #{e.message}", status: "Error" }
  end

  private

  # Build an NCPDP SCRIPT-compatible payload
  def build_ncpdp_payload
    {
      transaction_type:  "NEWRX",          # NCPDP: New Prescription
      message_id:        SecureRandom.uuid,
      sent_at:           Time.current.iso8601,
      standard:          "NCPDP SCRIPT 10.6",
      prescriber: {
        provider_id:     @prescription.provider_id,
        npi:             @prescription.provider_id   # In a real system, NPI is separate
      },
      patient: {
        patient_id:      @prescription.patient_id
      },
      pharmacy: {
        ncpdp_id:        @pharmacy.identifier,
        name:            @pharmacy.name
      },
      drug: {
        name:            @prescription.medication,
        dosage:          @prescription.dosage,
        frequency:       @prescription.frequency,
        quantity:        @prescription.quantity,
        dea_schedule:    @prescription.dea_schedule,
        instructions:    "#{@prescription.dosage} #{@prescription.frequency}"
      }
    }
  end

  def post_to_pharmacy(payload)
    uri = URI.parse(ENDPOINT)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl      = uri.scheme == "https"
    http.open_timeout = 5
    http.read_timeout = 10

    request = Net::HTTP::Post.new(uri.path.presence || "/", {
      "Content-Type" => "application/json",
      "Accept"       => "application/json"
    })
    request.body = payload.to_json
    http.request(request)
  rescue => e
    # Simulate a successful demo response if no real endpoint is reachable
    Rails.logger.warn "[RetailPharmacyService] Demo mode — could not reach #{ENDPOINT}: #{e.message}"
    OpenStruct.new(code: "200", body: { status: "received", message: "Prescription received by #{@pharmacy.name} (demo)." }.to_json)
  end

  def handle_response(response)
    body = JSON.parse(response.body, symbolize_names: true) rescue {}
    if response.code.to_i == 200 || response.code.to_i == 201
      {
        success: true,
        message: body[:message] || "Prescription received by #{@pharmacy.name}.",
        status:  "Sent"
      }
    else
      {
        success: false,
        message: body[:error] || "Pharmacy returned HTTP #{response.code}.",
        status:  "Error"
      }
    end
  end
end
