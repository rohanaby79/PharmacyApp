# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  private

  def authenticate_user!
    token = request.headers["Authorization"] || session[:auth_token]
    unless AuthToken.exists?(token: token)
      respond_to do |format|
        format.turbo_stream { redirect_to login_path, status: :see_other }
        format.html { redirect_to login_path, alert: "Please log in" }
        format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
      end
    end
  end

  def authenticate_doctor!
    token = request.headers["Authorization"]
    @auth_token = AuthToken.find_by(token: token)
    return if @auth_token&.valid_token?

    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def current_doctor
    @auth_token&.doctor
  end
end
