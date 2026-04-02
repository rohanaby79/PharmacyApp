# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  private

  def authenticate_user!
    token = request.headers["Authorization"] || session[:auth_token]
    unless AuthToken.exists?(token: token)
      redirect_to login_path
    end
  end
end