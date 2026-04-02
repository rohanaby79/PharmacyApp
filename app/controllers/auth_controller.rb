class AuthController < ApplicationController
  skip_before_action :verify_authenticity_token

  def login
    respond_to do |format|
      format.html { render :login }  # Renders app/views/auth/login.html.erb
      format.json do                  # Handles API requests
        doctor = Doctor.find_by(email: params[:email])

        if doctor&.authenticate(params[:password]) && doctor.active?
          token = AuthToken.create!(
            doctor: doctor,
            token: AuthToken.generate_token,
            expires_at: 24.hours.from_now
          )

          TransmissionLog.log(
            doctor_id: doctor.id,
            pharmacy_id: nil,
            prescription_id: nil,
            action: "doctor_login",
            status: "success",
            ip_address: request.remote_ip
          )

          render json: {
            message: "Login successful",
            token: token.token,
            doctor_name: doctor.name
          }, status: :ok
        else
          TransmissionLog.log(
            doctor_id: doctor&.id,
            pharmacy_id: nil,
            prescription_id: nil,
            action: "doctor_login",
            status: "failed",
            ip_address: request.remote_ip
          )
          render json: { error: "Invalid credentials or inactive account" }, status: :unauthorized
        end
      end
    end
  end

  def logout
    token = AuthToken.find_by(token: request.headers["Authorization"])
    if token
      token.destroy
      render json: { message: "Logged out successfully" }, status: :ok
    else
      render json: { error: "Token not found" }, status: :not_found
    end
  end
end