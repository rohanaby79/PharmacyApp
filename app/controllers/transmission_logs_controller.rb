class TransmissionLogsController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    # To view the log, verify the token
    before_action :authenticate_doctor!
  
    # GET /transmission_logs 
    def index
      logs = TransmissionLog.order(created_at: :desc)
  
      render json: logs.map { |log|
        {
          id:              log.id,
          action:          log.action,
          status:          log.status,
          doctor_id:       log.doctor_id,
          pharmacy_id:     log.pharmacy_id,
          prescription_id: log.prescription_id,
          ip_address:      log.ip_address,
          timestamp:       log.created_at
        }
      }, status: :ok
    end
  
    private
  
    # Check if there are valid tokens in the request header
    def authenticate_doctor!
      token = request.headers["Authorization"]
      auth_token = AuthToken.find_by(token: token)
  
      # Access is denied if the token does not exist or has expired
      unless auth_token&.valid_token?
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end
  end