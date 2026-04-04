# app/controllers/prescription_exports_controller.rb
# Epic 5 — Alternative Transmission (manual export / printable fallback)
class PrescriptionExportsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_doctor!

  # POST /prescription_exports
  # Generate and save a prescription export file (JSON or CSV).
  def create
    prescription_id = params[:prescription_id]
    file_format     = params[:file_format].presence || "json"

    prescription_data = {
      prescription_id: prescription_id,
      doctor_id:       current_doctor.id,
      doctor_name:     current_doctor.name,
      license_number:  current_doctor.license_number,
      pharmacy_id:     params[:pharmacy_id],
      medication:      params[:medication],
      dosage:          params[:dosage],
      frequency:       params[:frequency],
      quantity:        params[:quantity],
      patient_id:      params[:patient_id],
      instructions:    params[:instructions],
      exported_at:     Time.current.iso8601
    }

    file_content = build_file_content(prescription_data, file_format)
    file_name    = "prescription_#{prescription_id}_#{Time.current.to_i}.#{file_format}"
    file_path    = Rails.root.join("storage", file_name)
    File.write(file_path, file_content)

    export = PrescriptionExport.create!(
      prescription_id: prescription_id,
      doctor_id:       current_doctor.id,
      file_path:       file_path.to_s,
      file_format:     file_format,
      exported_at:     Time.current
    )

    TransmissionLog.log(
      doctor_id:       current_doctor.id,
      pharmacy_id:     params[:pharmacy_id],
      prescription_id: prescription_id,
      action:          "prescription_exported",
      status:          "success",
      ip_address:      request.remote_ip
    )

    render json: {
      message:     "Prescription exported successfully.",
      file_name:   file_name,
      file_format: file_format,
      export_id:   export.id
    }, status: :created

  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def build_file_content(data, format)
    case format
    when "json"
      JSON.pretty_generate(data)
    when "csv"
      keys   = data.keys.map(&:to_s)
      values = data.values.map { |v| v.to_s.include?(",") ? "\"#{v}\"" : v.to_s }
      [keys.join(","), values.join(",")].join("\n")
    else
      raise ArgumentError, "Unsupported file format: #{format}"
    end
  end
end
