# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  before_action :authenticate_user!
  # Force HTML format — Turbo Drive sends a turbo_stream Accept header on redirects
  # which would cause Rails to look for a .turbo_stream template that doesn't exist.
  before_action { request.format = :html }

  def index
    token = session[:auth_token]
    @doctor = AuthToken.find_by(token: token)&.doctor
  end
end