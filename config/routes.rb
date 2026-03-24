Rails.application.routes.draw do
  namespace :api do
    # Pharmacies search
    get 'pharmacies', to: 'pharmacies#index'

    # Create electronic prescription
    post 'prescriptions', to: 'prescriptions#create'
  end
end