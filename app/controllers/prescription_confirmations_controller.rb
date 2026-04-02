class PrescriptionConfirmationsController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_doctor!
  
    # POST /prescription_confirmations — The pharmacy sent a confirmation.
    def create
      confirmation = PrescriptionConfirmation.receive_confirmation(
        prescription_id: params[:prescription_id],
        pharmacy_id:     params[:pharmacy_id],
        status:          params[:status],
        message:         params[:message]
      )
  
      # Story 18 — Meanwhile, record the audit log
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
  
    # GET /prescription_confirmations/:prescription_id — Check the confirmation status of a certain prescription
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
  
    def authenticate_doctor!
      token = request.headers["Authorization"]
      @auth_token = AuthToken.find_by(token: token)
      unless @auth_token&.valid_token?
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end
  
    def current_doctor
      @auth_token.doctor
    end
  end