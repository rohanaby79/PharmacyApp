# app/controllers/prescription_confirmations_controller.rb
# Epic 4 — Pharmacy Response Handling
class PrescriptionConfirmationsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_doctor!

  # POST /prescription_confirmations
  # Receive a confirmation/status update from the pharmacy.
  def create
    confirmation = PrescriptionConfirmation.receive_confirmation(
      prescription_id: params[:prescription_id],
      pharmacy_id:     params[:pharmacy_id],
      status:          params[:status],
      message:         params[:message]
    )

    # Keep the parent prescription in sync with pharmacy status
    prescription = Prescription.find_by(id: params[:prescription_id])
    if prescription
      synced_status = map_confirmation_to_prescription_status(params[:status])
      prescription.update(status: synced_status)
    end

    TransmissionLog.log(
      doctor_id:       current_doctor.id,
      pharmacy_id:     params[:pharmacy_id],
      prescription_id: params[:prescription_id],
      action:          "prescription_confirmation_received",
      status:          params[:status],
      ip_address:      request.remote_ip
    )

    render json: {
      message:      "Confirmation received",
      confirmation: {
        id:              confirmation.id,
        prescription_id: confirmation.prescription_id,
        pharmacy_id:     confirmation.pharmacy_id,
        status:          confirmation.status,
        message:         confirmation.message,
        confirmed_at:    confirmation.confirmed_at
      }
    }, status: :created

  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # GET /prescription_confirmations/:prescription_id
  # Check confirmation history for a prescription.
  def show
    confirmations = PrescriptionConfirmation.where(
      prescription_id: params[:prescription_id]
    ).order(confirmed_at: :desc)

    render json: confirmations.map { |c|
      {
        id:              c.id,
        prescription_id: c.prescription_id,
        pharmacy_id:     c.pharmacy_id,
        status:          c.status,
        message:         c.message,
        confirmed_at:    c.confirmed_at
      }
    }, status: :ok
  end

  private

  # Map NCPDP/pharmacy confirmation statuses → Prescription STATUSES
  def map_confirmation_to_prescription_status(confirmation_status)
    case confirmation_status
    when "received"          then "Received"
    when "ready_for_pickup"  then "Ready"
    when "issue"             then "Error"
    else confirmation_status.capitalize
    end
  end
end
