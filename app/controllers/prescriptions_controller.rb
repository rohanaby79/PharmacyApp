# app/controllers/prescriptions_controller.rb
# Epic 2 – Prescription instructions (add/print/history)
# Epic 5 – Printable prescription fallback
# Epic 6 – All actions log to TransmissionLog
class PrescriptionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_doctor!

  # POST /prescriptions/:id/instructions
  def add_instructions
    instruction = PrescriptionInstruction.create!(
      prescription_id: params[:id].to_i,
      medication:      params[:medication],
      dosage:          params[:dosage],
      frequency:       params[:frequency],
      duration:        params[:duration],
      notes:           params[:notes] || "",
      doctor_id:       current_doctor.id,
      patient_id:      params[:patient_id],
      pharmacy_id:     params[:pharmacy_id],
      provider_id:     params[:provider_id],
      quantity:        params[:quantity]
    )

    TransmissionLog.log(
      doctor_id:       current_doctor.id,
      pharmacy_id:     params[:pharmacy_id],
      prescription_id: params[:id],
      action:          "instructions_added",
      status:          "success",
      ip_address:      request.remote_ip
    )

    render json: {
      message:         "Medication instructions added successfully.",
      prescription_id: params[:id],
      instructions: {
        medication: instruction.medication,
        dosage:     instruction.dosage,
        frequency:  instruction.frequency,
        duration:   instruction.duration,
        notes:      instruction.notes,
        added_at:   instruction.created_at
      }
    }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # GET /prescriptions/history
  def history
    instructions = PrescriptionInstruction.for_doctor(current_doctor.id)
    render json: instructions.map { |ins|
      {
        id:              ins.id,
        prescription_id: ins.prescription_id,
        medication:      ins.medication,
        dosage:          ins.dosage,
        frequency:       ins.frequency,
        duration:        ins.duration,
        notes:           ins.notes,
        patient_id:      ins.patient_id,
        pharmacy_id:     ins.pharmacy_id,
        created_at:      ins.created_at
      }
    }, status: :ok
  end

  # GET /prescriptions/:id/print  — Epic 5: Printable prescription
  def print
    prescription_id = params[:id].to_i

    # Try PrescriptionInstruction first; fall back to the Prescription record itself
    instruction = PrescriptionInstruction.for_prescription(prescription_id)

    if instruction.nil?
      rx = Prescription.find_by(id: prescription_id)
      unless rx
        return render json: { error: "Prescription #{prescription_id} not found." }, status: :not_found
      end
      # Build a lightweight struct so build_print_html works without changes
      instruction = OpenStruct.new(
        medication:  rx.medication,
        dosage:      rx.dosage,
        frequency:   rx.frequency,
        duration:    "As directed",
        notes:       "",
        quantity:    rx.quantity,
        patient_id:  rx.patient_id,
        provider_id: rx.provider_id,
        pharmacy_id: rx.pharmacy_id
      )
    end

    TransmissionLog.log(
      doctor_id:       current_doctor.id,
      pharmacy_id:     instruction.pharmacy_id,
      prescription_id: prescription_id,
      action:          "prescription_printed",
      status:          "success",
      ip_address:      request.remote_ip
    )

    render html: build_print_html(instruction, prescription_id).html_safe
  end

  private

  def build_print_html(ins, rx_id)
    <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <title>Prescription ##{rx_id}</title>
        <style>
          * { box-sizing: border-box; margin: 0; padding: 0; }
          body { font-family: Arial, sans-serif; background: #f0f4f8; padding: 30px 20px; }
          .page { max-width: 750px; margin: 0 auto; background: #fff; border-radius: 12px;
                  box-shadow: 0 2px 12px rgba(0,0,0,0.10); overflow: hidden; }
          .header { background: #2c5f8a; padding: 28px 36px; display: flex;
                    justify-content: space-between; align-items: center; }
          .header h1 { font-size: 20px; color: #fff; }
          .header p  { font-size: 12px; color: rgba(255,255,255,0.75); margin-top: 4px; }
          .rx-badge  { background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.3);
                       border-radius: 8px; padding: 8px 16px; text-align: center; }
          .rx-sym    { font-size: 26px; font-weight: bold; color: #fff; font-style: italic; }
          .rx-id     { font-size: 10px; color: rgba(255,255,255,0.7); letter-spacing: 1px; }
          .body      { padding: 28px 36px; }
          .grid      { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px; }
          .card      { background: #f8faff; border: 1px solid #dde8f7; border-radius: 10px; overflow: hidden; }
          .card-full { grid-column: 1 / -1; }
          .card-hdr  { background: #2c5f8a; padding: 8px 14px; font-size: 11px;
                       font-weight: bold; color: #fff; text-transform: uppercase; }
          .card-body { padding: 12px 14px; }
          .fl { font-size: 10px; font-weight: bold; color: #6b7fa3; text-transform: uppercase; margin-bottom: 2px; }
          .fv { font-size: 13px; font-weight: 500; color: #1a1a2e; margin-bottom: 8px; }
          .med  { font-size: 18px; font-weight: bold; color: #2c5f8a; margin-bottom: 10px;
                  padding-bottom: 10px; border-bottom: 1px solid #dde8f7; }
          .pills { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 10px; }
          .pill  { background: #e8f0fe; border: 1px solid #c5d8fc; border-radius: 20px;
                   padding: 3px 10px; font-size: 11px; color: #2c5f8a; }
          .pill span { color: #6b7fa3; margin-right: 3px; }
          .notes { background: #fffbeb; border: 1px solid #fde68a; border-radius: 6px;
                   padding: 8px 12px; font-size: 12px; color: #78350f; }
          .sig-row { margin-top: 22px; padding-top: 18px; border-top: 1px dashed #dde8f7;
                     display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
          .sig-label { font-size: 10px; font-weight: bold; color: #6b7fa3;
                       text-transform: uppercase; margin-bottom: 22px; }
          .sig-line  { border-bottom: 1.5px solid #2c5f8a; margin-bottom: 5px; }
          .sig-cap   { font-size: 10px; color: #6b7fa3; }
          .footer    { background: #f0f4fb; border-top: 1px solid #dde8f7; padding: 12px 36px;
                       display: flex; justify-content: space-between; }
          .footer p  { font-size: 10px; color: #8899b8; }
          .stamp     { background: #d5f5e3; border: 1px solid #82e0aa; border-radius: 5px;
                       padding: 3px 10px; font-size: 10px; font-weight: bold; color: #1e8449; }
          .print-btn { text-align: center; padding: 16px; }
          .print-btn button { background: #2c5f8a; color: white; border: none; padding: 10px 28px;
                              border-radius: 8px; font-size: 14px; font-weight: bold; cursor: pointer; }
          @media print { .print-btn { display: none; } body { background: white; padding: 0; }
                          .page { box-shadow: none; } }
        </style>
      </head>
      <body>
        <div class="print-btn"><button onclick="window.print()">&#128438; Print Prescription</button></div>
        <div class="page">
          <div class="header">
            <div>
              <h1>Pharmacy Prescription System</h1>
              <p>Dr. #{current_doctor.name} &middot; License: #{current_doctor.license_number}</p>
            </div>
            <div class="rx-badge">
              <div class="rx-sym">Rx</div>
              <div class="rx-id">##{rx_id}</div>
            </div>
          </div>
          <div class="body">
            <div class="grid">
              <div class="card">
                <div class="card-hdr">Patient</div>
                <div class="card-body">
                  <div class="fl">Patient ID</div><div class="fv">#{ins.patient_id || 'N/A'}</div>
                  <div class="fl">Provider ID</div><div class="fv">#{ins.provider_id || 'N/A'}</div>
                </div>
              </div>
              <div class="card">
                <div class="card-hdr">Doctor</div>
                <div class="card-body">
                  <div class="fl">Name</div><div class="fv">Dr. #{current_doctor.name}</div>
                  <div class="fl">License</div><div class="fv">#{current_doctor.license_number}</div>
                </div>
              </div>
              <div class="card card-full">
                <div class="card-hdr">Medication &amp; Instructions</div>
                <div class="card-body">
                  <div class="med">#{ins.medication}</div>
                  <div class="pills">
                    <div class="pill"><span>Dosage</span>#{ins.dosage}</div>
                    <div class="pill"><span>Frequency</span>#{ins.frequency}</div>
                    <div class="pill"><span>Duration</span>#{ins.duration}</div>
                    #{ins.quantity.present? ? "<div class='pill'><span>Qty</span>#{ins.quantity}</div>" : ''}
                  </div>
                  #{ins.notes.present? ? "<div class='notes'>#{ins.notes}</div>" : ''}
                </div>
              </div>
              <div class="card card-full">
                <div class="card-hdr">Pharmacy</div>
                <div class="card-body">
                  <div class="fl">Pharmacy ID</div><div class="fv">#{ins.pharmacy_id || 'N/A'}</div>
                </div>
              </div>
            </div>
            <div class="sig-row">
              <div>
                <div class="sig-label">Doctor Signature</div>
                <div class="sig-line"></div>
                <div class="sig-cap">Dr. #{current_doctor.name} &middot; #{current_doctor.license_number}</div>
              </div>
              <div>
                <div class="sig-label">Date Signed</div>
                <div class="sig-line"></div>
                <div class="sig-cap">#{Time.now.strftime("%B %-d, %Y")}</div>
              </div>
            </div>
          </div>
          <div class="footer">
            <p>PharmacyApp &middot; #{Time.now.strftime("%B %-d, %Y %I:%M %p")}</p>
            <div class="stamp">&#10003; Valid Prescription</div>
          </div>
        </div>
      </body>
      </html>
    HTML
  end
end
