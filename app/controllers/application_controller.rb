# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  # ─── Shared Authentication Helpers ────────────────────────────────────────
  #
  # Two helpers are provided so controllers can choose the right one:
  #
  #   authenticate_user!  → used by HTML/session-based flows (Dashboard, login redirect)
  #   authenticate_doctor! → used by JSON/API flows (token in Authorization header OR session)
  #
  # Both set @auth_token so current_doctor is always available after either call.

  private

  # HTML session-based auth (used by DashboardController)
  def authenticate_user!
    token_value = session[:auth_token] || request.headers["Authorization"]
    @auth_token = AuthToken.find_by(token: token_value)

    unless @auth_token&.valid_token?
      respond_to do |format|
        format.html         { redirect_to login_path, alert: "Please log in." }
        format.turbo_stream { redirect_to login_path, status: :see_other }
        format.json         { render json: { error: "Unauthorized" }, status: :unauthorized }
      end
    end
  end

  # Token / JSON API auth (used by all API controllers and JSON endpoints)
  def authenticate_doctor!
    token_value = request.headers["Authorization"] || session[:auth_token]
    @auth_token = AuthToken.find_by(token: token_value)

    unless @auth_token&.valid_token?
      respond_to do |format|
        format.html         { redirect_to login_path, alert: "Please log in." }
        format.json         { render json: { error: "Unauthorized" }, status: :unauthorized }
        format.any          { render json: { error: "Unauthorized" }, status: :unauthorized }
      end
    end
  end

  # Always available after either authenticate_* call
  def current_doctor
    @auth_token&.doctor
  end
end
