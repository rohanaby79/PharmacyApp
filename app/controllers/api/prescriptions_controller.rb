module Api
  class PrescriptionsController < ApplicationController
    protect_from_forgery with: :null_session

    def create
      prescription_params = params.permit(:pharmacy_id, :medication, :dosage, :frequency, :quantity, :patient_id, :provider_id)
      render json: { status: "success", prescription: prescription_params }, status: :created
    end
  end
end