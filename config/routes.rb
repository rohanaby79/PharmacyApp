Rails.application.routes.draw do
  # ─── Root & Auth ──────────────────────────────────────────────────────────
  root "auth#login"
  get    "/login",        to: "auth#login",  as: :login
  post   "/auth/login",   to: "auth#login"
  delete "/auth/logout",  to: "auth#logout"

  # ─── Dashboard ────────────────────────────────────────────────────────────
  get "/dashboard", to: "dashboard#index", as: "dashboard"

  # ─── Transmission Logs (Epic 6) ───────────────────────────────────────────
  get "/transmission_logs", to: "transmission_logs#index"

  # ─── Prescription Confirmations (Epic 4) ──────────────────────────────────
  post "/prescription_confirmations",                   to: "prescription_confirmations#create"
  get  "/prescription_confirmations/:prescription_id",  to: "prescription_confirmations#show",
       as: "prescription_confirmation"

  # ─── Prescription Exports / Alt-Transmission (Epic 5) ────────────────────
  post "/prescription_exports", to: "prescription_exports#create"

  # ─── Prescription Web Routes ──────────────────────────────────────────────
  # History must come before :id routes to avoid routing conflicts
  get  "/prescriptions/history",              to: "prescriptions#history",         as: "prescriptions_history"
  post "/prescriptions/:id/instructions",     to: "prescriptions#add_instructions"
  get  "/prescriptions/:id/print",            to: "prescriptions#print",           as: "print_prescription"

  # ─── API Namespace ────────────────────────────────────────────────────────
  namespace :api do
    # Epic 1 – Pharmacy discovery
    get  "pharmacies",                        to: "pharmacies#index"

    # Epic 2 – Prescription creation
    post "prescriptions",                     to: "prescriptions#create"

    # Epic 3 – Transmission
    post "prescriptions/:id/transmit",        to: "prescriptions#transmit"

    # Epic 4 – Status updates and error reporting
    patch "prescriptions/:id/status",         to: "prescriptions#update_status"
    patch "prescriptions/:id/error",          to: "prescriptions#report_error"
  end
end
