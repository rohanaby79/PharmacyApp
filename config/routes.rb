Rails.application.routes.draw do
  namespace :api do
  get 'pharmacies', to: 'pharmacies#index'
  end
end