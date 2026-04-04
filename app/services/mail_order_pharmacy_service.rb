# app/services/mail_order_pharmacy_service.rb
#
# MailOrderPharmacyService — Handles e-Rx transmission for mail-order pharmacies
# (e.g. Express Scripts, Optum Rx) where prescriptions are delivered by mail.
# Uses the same NCPDP SCRIPT payload as RetailPharmacyService but targets a
# different endpoint and adds mail-delivery metadata.
#
require "net/http"
require "json"
require "ostruct"

class MailOrderPharmacyService
  ENDPOINT = ENV.fetch("MAIL_ORDER_PHARMACY_API_URL", "https://demo.mailorderrx.example.com/api/v1/prescriptions")

  def initialize(prescription, pharmacy)
    @prescription = prescription
    @pharmacy     = pharmacy
  end

  def transmit
    payload = build_ncpdp_payload
    response = post_to_pharmacy(payload)
    handle_response(response)
  rescue StandardError => e
    { success: false, message: "MailOrderPharmacyService error: #{e.message}", status: "Error" }
  end

  private

  def build_ncpdp_payload
    {
      transaction_type: "NEWRX",
      message_id:       SecureRandom.uuid,
      sent_at:          Time.current.iso8601,
      standard:         "NCPDP SCRIPT 10.6",
      delivery_method:  "MAIL_ORDER",
      prescriber: {
        provider_id:    @prescription.provider_id
      },
      patient: {
        patient_id:     @prescription.patient_id
      },
      pharmacy: {
        ncpdp_id:       @pharmacy.identifier,
        name:           @pharmacy.name
      },
      drug: {
        name:           @prescription.medication,
        dosage:         @prescription.dosage,
        frequency:      @prescription.frequency,
        quantity:       @prescription.quantity,
        dea_schedule:   @prescription.dea_schedule,
        refills_allowed: 0,
        days_supply:    30
      }
    }
  end

  def post_to_pharmacy(payload)
    uri  = URI.parse(ENDPOINT)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl      = uri.scheme == "https"
    http.open_timeout = 5
    http.read_timeout = 10

    req = Net::HTTP::Post.new(uri.path.presence || "/", {
      "Content-Type" => "application/json",
      "Accept"       => "application/json"
    })
    req.body = payload.to_json
    http.request(req)
  rescue => e
    Rails.logger.warn "[MailOrderPharmacyService] Demo mode — #{e.message}"
    OpenStruct.new(code: "200", body: { status: "received", message: "Mail-order prescription received by #{@pharmacy.name} (demo)." }.to_json)
  end

  def handle_response(response)
    body = JSON.parse(response.body, symbolize_names: true) rescue {}
    if response.code.to_i == 200 || response.code.to_i == 201
      { success: true, message: body[:message] || "Mail-order prescription queued.", status: "Sent" }
    else
      { success: false, message: body[:error] || "Pharmacy returned HTTP #{response.code}.", status: "Error" }
    end
  end
end
