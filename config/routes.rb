Rails.application.routes.draw do
  namespace :api do
    get  'pharmacies',    to: 'pharmacies#index'
    post 'prescriptions', to: 'prescriptions#create'
  end

  # story 20
  post   "/auth/login",  to: "auth#login"
  delete "/auth/logout", to: "auth#logout"

  # story 18
  get "/transmission_logs", to: "transmission_logs#index"

  # story 13
  post "/prescription_confirmations",                  to: "prescription_confirmations#create"
  get  "/prescription_confirmations/:prescription_id", to: "prescription_confirmations#show"

  # story 17
  post "/prescription_exports", to: "prescription_exports#create"

  # story 19 — must be BEFORE /:id routes
  get  "/prescriptions/history",          to: "prescriptions#history"

  # story 6
  post "/prescriptions/:id/instructions", to: "prescriptions#add_instructions"

  # story 16
  get  "/prescriptions/:id/print",        to: "prescriptions#print"
end
