# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    # Get the logged-in doctor from session
    token = session[:auth_token]
    @doctor = AuthToken.find_by(token: token)&.doctor
  end
end