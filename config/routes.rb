Rails.application.routes.draw do
  namespace :api do
    get  'pharmacies',                        to: 'pharmacies#index'
    post 'prescriptions',                     to: 'prescriptions#create'
    patch 'prescriptions/:id/status',         to: 'prescriptions#update_status'
    patch 'prescriptions/:id/error',          to: 'prescriptions#report_error'
  end
  root to: redirect('/api/pharmacies')
end
