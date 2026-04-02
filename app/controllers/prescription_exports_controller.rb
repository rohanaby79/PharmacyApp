class PrescriptionExportsController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_doctor!
  
    # POST /prescription_exports — Export the prescription file
    def create
      prescription_id = params[:prescription_id]
      file_format     = params[:file_format] || "json"
  
      # Construct prescription data
      prescription_data = {
        prescription_id: prescription_id,
        doctor_id:       current_doctor.id,
        doctor_name:     current_doctor.name,
        pharmacy_id:     params[:pharmacy_id],
        medication:      params[:medication],
        dosage:          params[:dosage],
        instructions:    params[:instructions],
        exported_at:     Time.current.iso8601
      }
  
      # Generate file content
      file_content = case file_format
      when "json"
        JSON.pretty_generate(prescription_data)
      when "csv"
        prescription_data.keys.join(",") + "\n" +
        prescription_data.values.join(",")
      end
  
      # Save the file to the storage directory
      file_name = "prescription_#{prescription_id}_#{Time.current.to_i}.#{file_format}"
      file_path = Rails.root.join("storage", file_name)
      File.write(file_path, file_content)
  
      # Record to the database (for auditing)
      export = PrescriptionExport.create!(
        prescription_id: prescription_id,
        doctor_id:       current_doctor.id,
        file_path:       file_path.to_s,
        file_format:     file_format,
        exported_at:     Time.current
      )
  
      # Story 18 
      TransmissionLog.log(
        doctor_id:       current_doctor.id,
        pharmacy_id:     params[:pharmacy_id],
        prescription_id: prescription_id,
        action:          "prescription_exported",
        status:          "success",
        ip_address:      request.remote_ip
      )
  
      render json: {
        message:     "Prescription exported successfully",
        file_name:   file_name,
        file_format: file_format,
        file_path:   file_path.to_s,
        export_id:   export.id
      }, status: :created
  
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  
    private
  
    def authenticate_doctor!
      token = request.headers["Authorization"]
      @auth_token = AuthToken.find_by(token: token)
      unless @auth_token&.valid_token?
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end
  
    def current_doctor
      @auth_token.doctor
    end
  end