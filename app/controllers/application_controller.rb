# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  private

  def authenticate_user!
    token = request.headers["Authorization"] || session[:auth_token]
    unless AuthToken.exists?(token: token)
      respond_to do |format|
        format.turbo_stream { redirect_to login_path, status: :see_other }  # force full redirect
        format.html { redirect_to login_path, alert: "Please log in" }
      end
    end
  end
end