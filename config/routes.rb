Rails.application.routes.draw do
  # Root route
  root "auth#login"    # go to login page on start
  get "/login", to: "auth#login"

  # Authentication
  post   "/auth/login",  to: "auth#login"
  delete "/auth/logout", to: "auth#logout"

  # Dashboard
  get "/dashboard", to: "dashboard#index", as: "dashboard"

  # Transmission logs
  get "/transmission_logs", to: "transmission_logs#index"

  # Prescription confirmations
  post "/prescription_confirmations",                  to: "prescription_confirmations#create"
  get  "/prescription_confirmations/:prescription_id", to: "prescription_confirmations#show"

  # Prescription exports
  post "/prescription_exports", to: "prescription_exports#create"

  # Prescriptions history (must be before /:id routes)
  get  "/prescriptions/history", to: "prescriptions#history"

  # Prescription instructions
  post "/prescriptions/:id/instructions", to: "prescriptions#add_instructions"

  # Prescription print
  get  "/prescriptions/:id/print", to: "prescriptions#print"

  # API namespace
  namespace :api do
    get   'pharmacies',                     to: 'pharmacies#index'
    post  'prescriptions',                  to: 'prescriptions#create'
    patch 'prescriptions/:id/status',       to: 'prescriptions#update_status'
    patch 'prescriptions/:id/error',        to: 'prescriptions#report_error'
  end
end