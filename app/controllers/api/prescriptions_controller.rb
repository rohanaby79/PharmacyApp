module Api
  class PrescriptionsController < ApplicationController
    protect_from_forgery with: :null_session

    def create
      availability = PharmacyAvailabilityService.new(params[:pharmacy_id]).check_availability
      unless availability[:supported]
        return render json: { status: "error", errors: [availability[:message]] }, status: :unprocessable_entity
      end

      validator = PrescriptionValidationService.new(prescription_params)
      unless validator.valid?
        return render json: { status: "error", errors: validator.errors }, status: :unprocessable_entity
      end

      dea = DeaVerificationService.new(
        provider_id:  params[:provider_id],
        dea_number:   params[:dea_number],
        dea_schedule: params[:dea_schedule]
      )
      unless dea.authorized?
        return render json: { status: "error", errors: [dea.verify[:message]], dea_blocked: true }, status: :forbidden
      end

      @prescription = Prescription.new(prescription_params)
      if @prescription.save
        render json: { status: "success", message: "Prescription saved.", prescription: @prescription }, status: :created
      else
        render json: { status: "error", errors: @prescription.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update_status
      @prescription = Prescription.find(params[:id])
      new_status = params[:status]
      unless Prescription::STATUSES.include?(new_status)
        return render json: { status: "error", message: "Invalid status '#{new_status}'. Valid: #{Prescription::STATUSES.join(', ')}" }, status: :unprocessable_entity
      end
      if @prescription.update(status: new_status)
        render json: { status: "success", message: "Status updated to '#{new_status}'.", prescription: @prescription }
      else
        render json: { status: "error", errors: @prescription.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { status: "error", message: "Prescription not found." }, status: :not_found
    end

    def report_error
      @prescription = Prescription.find(params[:id])
      error_msg = params[:error_message].presence || "Unknown pharmacy error."
      if @prescription.update(status: "Error", error_message: error_msg)
        render json: { status: "error_recorded", message: "Prescription marked as Error. Doctor notified.", prescription: @prescription }
      else
        render json: { status: "error", errors: @prescription.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { status: "error", message: "Prescription not found." }, status: :not_found
    end

    private

    def prescription_params
      params.permit(:pharmacy_id, :medication, :dosage, :frequency,
                    :quantity, :patient_id, :provider_id, :dea_schedule)
    end
  end
end