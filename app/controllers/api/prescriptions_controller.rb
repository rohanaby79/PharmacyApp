# app/controllers/api/prescriptions_controller.rb
#
# Covers:
#   Epic 2 – Prescription Creation  (create)
#   Epic 3 – Prescription Transmission (transmit)
#   Epic 4 – Response Handling  (update_status, report_error)
#   Epic 6 – Logging & Compliance   (TransmissionLog.log throughout)
#
module Api
  class PrescriptionsController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :authenticate_doctor!

    # POST /api/prescriptions
    # Creates a prescription as "Draft" after validation.
    def create
      # Epic 1 – Validate pharmacy accepts e-Rx
      availability = PharmacyAvailabilityService.new(params[:pharmacy_id]).check_availability
      unless availability[:supported]
        return render json: { status: "error", errors: [availability[:message]] }, status: :unprocessable_entity
      end

      # Epic 2 – Validate prescription fields
      validator = PrescriptionValidationService.new(prescription_params)
      unless validator.valid?
        return render json: { status: "error", errors: validator.errors }, status: :unprocessable_entity
      end

      # Epic 6 – DEA check before saving
      dea = DeaVerificationService.new(
        provider_id:  params[:provider_id],
        dea_number:   params[:dea_number],
        dea_schedule: params[:dea_schedule]
      )
      unless dea.authorized?
        return render json: { status: "error", errors: [dea.verify[:message]], dea_blocked: true }, status: :forbidden
      end

      @prescription = Prescription.new(prescription_params.merge(status: "Draft"))
      if @prescription.save
        TransmissionLog.log(
          doctor_id:       current_doctor.id,
          pharmacy_id:     @prescription.pharmacy_id,
          prescription_id: @prescription.id,
          action:          "prescription_created",
          status:          "Draft",
          ip_address:      request.remote_ip
        )
        render json: { status: "success", message: "Prescription saved as Draft.", prescription: @prescription }, status: :created
      else
        render json: { status: "error", errors: @prescription.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # POST /api/prescriptions/:id/transmit
    # Transmits a Draft prescription to the pharmacy via the adapter layer.
    def transmit
      @prescription = Prescription.find(params[:id])

      unless @prescription.status == "Draft"
        return render json: { status: "error", message: "Only Draft prescriptions can be transmitted. Current status: #{@prescription.status}." }, status: :unprocessable_entity
      end

      # Epic 3 – Dispatch via modular adapter layer
      result = PharmacyAdapter.dispatch(@prescription)

      new_status = result[:success] ? "Sent" : "Error"
      @prescription.update(status: new_status, transmitted_at: Time.current, error_message: result[:success] ? nil : result[:message])

      # Epic 6 – Audit log
      TransmissionLog.log(
        doctor_id:       current_doctor.id,
        pharmacy_id:     @prescription.pharmacy_id,
        prescription_id: @prescription.id,
        action:          "prescription_transmitted",
        status:          new_status,
        ip_address:      request.remote_ip
      )

      if result[:success]
        render json: { status: "success", message: result[:message], prescription: @prescription }, status: :ok
      else
        render json: { status: "error", message: result[:message], prescription: @prescription }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { status: "error", message: "Prescription not found." }, status: :not_found
    end

    # PATCH /api/prescriptions/:id/status
    # Allows pharmacy (or internal system) to push a status update.
    def update_status
      @prescription = Prescription.find(params[:id])
      new_status    = params[:status]

      unless Prescription::STATUSES.include?(new_status)
        return render json: { status: "error", message: "Invalid status '#{new_status}'. Valid values: #{Prescription::STATUSES.join(', ')}" }, status: :unprocessable_entity
      end

      if @prescription.update(status: new_status)
        TransmissionLog.log(
          doctor_id:       current_doctor.id,
          pharmacy_id:     @prescription.pharmacy_id,
          prescription_id: @prescription.id,
          action:          "status_updated",
          status:          new_status,
          ip_address:      request.remote_ip
        )
        render json: { status: "success", message: "Status updated to '#{new_status}'.", prescription: @prescription }
      else
        render json: { status: "error", errors: @prescription.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { status: "error", message: "Prescription not found." }, status: :not_found
    end

    # PATCH /api/prescriptions/:id/error
    # Records an error message from the pharmacy.
    def report_error
      @prescription = Prescription.find(params[:id])
      error_msg     = params[:error_message].presence || "Unknown pharmacy error."

      if @prescription.update(status: "Error", error_message: error_msg)
        TransmissionLog.log(
          doctor_id:       current_doctor.id,
          pharmacy_id:     @prescription.pharmacy_id,
          prescription_id: @prescription.id,
          action:          "prescription_error_reported",
          status:          "Error",
          ip_address:      request.remote_ip
        )
        render json: { status: "error_recorded", message: "Prescription marked as Error.", prescription: @prescription }
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
