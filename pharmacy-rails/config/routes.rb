Rails.application.routes.draw do

  root "prescriptions#home"

  post "/prescriptions/:id/instructions", to: "prescriptions#add_instructions"
  get  "/prescriptions/:id/print",        to: "prescriptions#print"
  get  "/prescriptions/:id/history",      to: "prescriptions#history"

end