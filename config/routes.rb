Rails.application.routes.draw do
  namespace :api do
    # Pharmacies search
    get 'pharmacies', to: 'pharmacies#index'

    # Create electronic prescription
    post 'prescriptions', to: 'prescriptions#create'
  end

  # story 20
  post "/auth/login", to: "auth#login"
  delete "/auth/logout", to: "auth#logout"

  # story 18
  get "/transmission_logs", to: "transmission_logs#index"

  # story 13
  post "/prescription_confirmations",                    to: "prescription_confirmations#create"
  get  "/prescription_confirmations/:prescription_id",   to: "prescription_confirmations#show"

  # story 17
  post "/prescription_exports", to: "prescription_exports#create"
end