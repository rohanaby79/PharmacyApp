class PrescriptionsController < ActionController::Base

  def add_instructions
    prescription = Prescription.find_by_id(params[:id])
    unless prescription
      return render json: { success: false, message: "Prescription not found." }, status: :not_found
    end
    dosage    = params[:dosage]
    frequency = params[:frequency]
    duration  = params[:duration]
    notes     = params[:notes] || ""
    if dosage.blank? || frequency.blank? || duration.blank?
      return render json: { success: false, message: "Missing required fields: dosage, frequency, and duration are required." }, status: :bad_request
    end
    instructions = { dosage: dosage, frequency: frequency, duration: duration, notes: notes, added_at: Time.now.iso8601 }
    new_entry = { status: "instructions_added", message: "Instructions added: #{dosage}, #{frequency} for #{duration}.", timestamp: Time.now.iso8601 }
    updated_history = prescription[:status_history] + [new_entry]
    updated = Prescription.update(params[:id], { instructions: instructions, status_history: updated_history })
    render json: { success: true, message: "Medication instructions added successfully.", prescription: updated }, status: :ok
  end

  def print
    rx = Prescription.find_by_id(params[:id])
    unless rx
      return render json: { success: false, message: "Prescription not found." }, status: :not_found
    end
    instructions_html = if rx[:instructions]
      ins = rx[:instructions]
      notes_block = ins[:notes].present? ? "<div class='notes-box'><strong>Additional Notes</strong>#{ins[:notes]}</div>" : ""
      "<div class='med-name'>#{rx[:medication]}</div><div class='pills'><div class='pill'><span>Dosage</span>#{ins[:dosage]}</div><div class='pill'><span>Frequency</span>#{ins[:frequency]}</div><div class='pill'><span>Duration</span>#{ins[:duration]}</div></div>#{notes_block}"
    else
      "<div class='med-name'>#{rx[:medication]}</div><div class='no-instructions'>&#9888; No medication instructions added yet.</div>"
    end
    status_label = rx[:status].gsub("_", " ").split.map(&:capitalize).join(" ")
    issued_date  = Time.parse(rx[:created_at]).strftime("%B %-d, %Y") rescue rx[:created_at]
    html = <<~HTML
      <!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"/>
      <title>Prescription #{rx[:id]}</title>
      <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');
        *{box-sizing:border-box;margin:0;padding:0}
        body{font-family:'Inter',Arial,sans-serif;background:#f4f6f9;color:#1a1a2e;padding:40px 20px}
        .page{max-width:780px;margin:0 auto;background:#fff;border-radius:16px;box-shadow:0 4px 24px rgba(0,0,0,0.10);overflow:hidden}
        .header{background:linear-gradient(135deg,#1a3c5e,#2563a8);padding:32px 40px;display:flex;justify-content:space-between;align-items:center}
        .header h1{font-size:22px;font-weight:700;color:#fff}
        .header p{font-size:12px;color:rgba(255,255,255,0.7);margin-top:4px;line-height:1.6}
        .rx-badge{background:rgba(255,255,255,0.15);border:1px solid rgba(255,255,255,0.3);border-radius:10px;padding:10px 18px;text-align:center}
        .rx-badge .rx-sym{font-size:28px;font-weight:700;color:#fff;font-style:italic;line-height:1}
        .rx-badge .rx-id{font-size:11px;color:rgba(255,255,255,0.65);letter-spacing:1px}
        .status-bar{background:#eef4ff;border-bottom:1px solid #d0e3ff;padding:10px 40px;display:flex;align-items:center;gap:8px;font-size:12px;color:#2563a8}
        .status-dot{width:8px;height:8px;border-radius:50%;background:#2563a8}
        .body{padding:32px 40px}
        .grid-2{display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:24px}
        .card{background:#f8faff;border:1px solid #e2eaf7;border-radius:12px;overflow:hidden}
        .card-full{grid-column:1/-1}
        .card-header{background:#1a3c5e;padding:10px 16px;display:flex;align-items:center;gap:8px}
        .card-header .icon{width:18px;height:18px;background:rgba(255,255,255,0.2);border-radius:4px;font-size:10px;color:white;display:flex;align-items:center;justify-content:center}
        .card-header h3{font-size:11px;font-weight:600;color:#fff;text-transform:uppercase;letter-spacing:0.8px}
        .card-body{padding:14px 16px}
        .field{margin-bottom:10px}.field:last-child{margin-bottom:0}
        .field-label{font-size:10px;font-weight:600;color:#6b7fa3;text-transform:uppercase;letter-spacing:0.6px;margin-bottom:2px}
        .field-value{font-size:14px;font-weight:500;color:#1a1a2e}
        .med-name{font-size:20px;font-weight:700;color:#1a3c5e;margin-bottom:14px;padding-bottom:12px;border-bottom:1px solid #e2eaf7}
        .pills{display:flex;flex-wrap:wrap;gap:8px;margin-bottom:12px}
        .pill{background:#e8f0fe;border:1px solid #c5d8fc;border-radius:20px;padding:4px 12px;font-size:12px;font-weight:500;color:#1a3c5e}
        .pill span{color:#6b7fa3;font-weight:400;margin-right:4px}
        .notes-box{background:#fffbeb;border:1px solid #fde68a;border-radius:8px;padding:10px 12px;font-size:12px;color:#78350f;line-height:1.5}
        .notes-box strong{display:block;font-size:10px;text-transform:uppercase;color:#92400e;margin-bottom:2px}
        .no-instructions{background:#fff5f5;border:1px solid #fecaca;border-radius:8px;padding:10px 12px;font-size:12px;color:#b91c1c}
        .ph-grid{display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px}
        .sig-row{margin-top:28px;padding-top:24px;border-top:1px dashed #d0e3ff;display:grid;grid-template-columns:1fr 1fr;gap:24px}
        .sig-label{font-size:10px;font-weight:600;color:#6b7fa3;text-transform:uppercase;letter-spacing:0.6px;margin-bottom:28px}
        .sig-line{border-bottom:1.5px solid #1a3c5e;margin-bottom:6px}
        .sig-cap{font-size:11px;color:#6b7fa3}
        .footer{background:#f0f4fb;border-top:1px solid #e2eaf7;padding:14px 40px;display:flex;justify-content:space-between;align-items:center}
        .footer p{font-size:10px;color:#8899b8}
        .stamp{background:#dcfce7;border:1px solid #86efac;border-radius:6px;padding:4px 10px;font-size:10px;font-weight:600;color:#166534}
      </style></head><body>
      <div class="page">
        <div class="header">
          <div><h1>#{rx[:clinic_name]}</h1><p>#{rx[:clinic_address]}<br/>#{rx[:clinic_phone]}</p></div>
          <div class="rx-badge"><div class="rx-sym">Rx</div><div class="rx-id">#{rx[:id]}</div></div>
        </div>
        <div class="status-bar"><div class="status-dot"></div>Status: <strong>#{status_label}</strong> &nbsp;·&nbsp; Issued: #{issued_date}</div>
        <div class="body">
          <div class="grid-2">
            <div class="card"><div class="card-header"><div class="icon">P</div><h3>Patient</h3></div>
              <div class="card-body"><div class="field"><div class="field-label">Full Name</div><div class="field-value">#{rx[:patient_name]}</div></div>
              <div class="field"><div class="field-label">Date of Birth</div><div class="field-value">#{rx[:patient_dob]}</div></div></div></div>
            <div class="card"><div class="card-header"><div class="icon">D</div><h3>Prescribing Doctor</h3></div>
              <div class="card-body"><div class="field"><div class="field-label">Doctor Name</div><div class="field-value">#{rx[:doctor_name]}</div></div>
              <div class="field"><div class="field-label">License Number</div><div class="field-value">#{rx[:doctor_license]}</div></div></div></div>
            <div class="card card-full"><div class="card-header"><div class="icon">M</div><h3>Medication &amp; Instructions</h3></div>
              <div class="card-body">#{instructions_html}</div></div>
            <div class="card card-full"><div class="card-header"><div class="icon">Ph</div><h3>Pharmacy</h3></div>
              <div class="card-body"><div class="ph-grid">
                <div class="field"><div class="field-label">Pharmacy Name</div><div class="field-value">#{rx[:pharmacy_name]}</div></div>
                <div class="field"><div class="field-label">Address</div><div class="field-value">#{rx[:pharmacy_address]}</div></div>
                <div class="field"><div class="field-label">Phone</div><div class="field-value">#{rx[:pharmacy_phone]}</div></div>
              </div></div></div>
          </div>
          <div class="sig-row">
            <div><div class="sig-label">Doctor Signature</div><div class="sig-line"></div><div class="sig-cap">#{rx[:doctor_name]} · #{rx[:doctor_license]}</div></div>
            <div><div class="sig-label">Date Signed</div><div class="sig-line"></div><div class="sig-cap">MM / DD / YYYY</div></div>
          </div>
        </div>
        <div class="footer"><p>Generated by Pharmacy Prescription Integration System · #{Time.now.strftime("%B %-d, %Y")}</p><div class="stamp">&#10003; Valid Prescription</div></div>
      </div></body></html>
    HTML
    render html: html.html_safe
  end

  def history
    prescription = Prescription.find_by_id(params[:id])
    unless prescription
      return render json: { success: false, message: "Prescription not found." }, status: :not_found
    end
    sorted_history = prescription[:status_history].sort_by { |e| e[:timestamp] }
    status_colors = {
      "pending"            => { bg: "#fef9c3", border: "#fde047", text: "#713f12", dot: "#ca8a04" },
      "instructions_added" => { bg: "#f0fdf4", border: "#86efac", text: "#14532d", dot: "#16a34a" },
      "sent_to_pharmacy"   => { bg: "#dbeafe", border: "#93c5fd", text: "#1e3a5f", dot: "#2563eb" },
      "filled"             => { bg: "#dcfce7", border: "#86efac", text: "#14532d", dot: "#16a34a" },
      "dispensed"          => { bg: "#f3e8ff", border: "#d8b4fe", text: "#3b0764", dot: "#9333ea" },
      "cancelled"          => { bg: "#fee2e2", border: "#fca5a5", text: "#7f1d1d", dot: "#dc2626" }
    }
    timeline_html = sorted_history.each_with_index.map do |entry, index|
      c = status_colors[entry[:status]] || status_colors["pending"]
      is_last = index == sorted_history.length - 1
      label = entry[:status].gsub("_", " ").split.map(&:capitalize).join(" ")
      time = Time.parse(entry[:timestamp]) rescue nil
      date_str = time ? time.strftime("%B %-d, %Y") : entry[:timestamp]
      time_str = time ? time.strftime("%I:%M %p") : ""
      line = is_last ? "" : "<div style='width:2px;flex:1;background:#e2e8f0;margin-top:4px;'></div>"
      <<~HTML
        <div style="display:flex;gap:16px;margin-bottom:#{is_last ? '0' : '8px'};">
          <div style="display:flex;flex-direction:column;align-items:center;width:20px;flex-shrink:0;">
            <div style="width:14px;height:14px;border-radius:50%;background:#{c[:dot]};border:2px solid white;box-shadow:0 0 0 2px #{c[:dot]};margin-top:14px;"></div>
            #{line}
          </div>
          <div style="flex:1;background:#{c[:bg]};border:1px solid #{c[:border]};border-radius:10px;padding:12px 16px;margin-bottom:#{is_last ? '0' : '8px'};">
            <div style="display:flex;justify-content:space-between;gap:8px;">
              <span style="font-size:13px;font-weight:600;color:#{c[:text]};">#{label}</span>
              <span style="font-size:10px;color:#{c[:text]};opacity:0.75;white-space:nowrap;">#{date_str} · #{time_str}</span>
            </div>
            <p style="font-size:12px;color:#{c[:text]};opacity:0.85;margin-top:4px;line-height:1.5;">#{entry[:message]}</p>
          </div>
        </div>
      HTML
    end.join
    current_label = prescription[:status].gsub("_", " ").split.map(&:capitalize).join(" ")
    current_dot = (status_colors[prescription[:status]] || status_colors["pending"])[:dot]
    html = <<~HTML
      <!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"/>
      <title>History — #{prescription[:id]}</title>
      <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');
        *{box-sizing:border-box;margin:0;padding:0}
        body{font-family:'Inter',Arial,sans-serif;background:#f0f4f8;min-height:100vh;padding:40px 20px;color:#1a1a2e}
        .page{max-width:680px;margin:0 auto}
      </style></head><body>
      <div class="page">
        <div style="background:#1a3c5e;border-radius:16px 16px 0 0;padding:28px 32px;display:flex;justify-content:space-between;align-items:center;">
          <div>
            <p style="font-size:11px;color:rgba(255,255,255,0.55);text-transform:uppercase;letter-spacing:1px;margin-bottom:4px;">Prescription History</p>
            <h1 style="font-size:22px;font-weight:700;color:#fff;">#{prescription[:patient_name]}</h1>
            <p style="font-size:12px;color:rgba(255,255,255,0.65);margin-top:4px;">#{prescription[:medication]} · #{prescription[:id]}</p>
          </div>
          <div style="background:rgba(255,255,255,0.12);border:1px solid rgba(255,255,255,0.22);border-radius:10px;padding:10px 18px;text-align:center;">
            <div style="font-size:26px;font-weight:700;color:#fff;font-style:italic;line-height:1;">Rx</div>
            <div style="font-size:10px;color:rgba(255,255,255,0.6);margin-top:2px;letter-spacing:1px;">#{prescription[:id]}</div>
          </div>
        </div>
        <div style="background:#eef4ff;border-left:1px solid #d0e3ff;border-right:1px solid #d0e3ff;padding:10px 32px;display:flex;align-items:center;gap:24px;">
          <div style="display:flex;align-items:center;gap:6px;">
            <div style="width:8px;height:8px;border-radius:50%;background:#{current_dot};"></div>
            <span style="font-size:11px;color:#1a3c5e;">Current status: <strong>#{current_label}</strong></span>
          </div>
          <span style="font-size:11px;color:#6b7fa3;">#{sorted_history.length} event#{"s" if sorted_history.length != 1} recorded</span>
        </div>
        <div style="background:#fff;border-radius:0 0 16px 16px;border:1px solid #e2eaf7;border-top:none;padding:28px 32px;">
          <p style="font-size:11px;font-weight:600;color:#6b7fa3;text-transform:uppercase;letter-spacing:0.8px;margin-bottom:20px;">Timeline</p>
          #{timeline_html}
        </div>
        <div style="text-align:center;margin-top:16px;">
          <p style="font-size:10px;color:#a0aec0;">Generated by Pharmacy Prescription Integration System · #{Time.now.strftime("%B %-d, %Y")}</p>
        </div>
      </div></body></html>
    HTML
    render html: html.html_safe
  end

  def home
    html = <<~HTML
      <!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"/>
      <title>Pharmacy Prescription System</title>
      <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');
        *{box-sizing:border-box;margin:0;padding:0}
        body{font-family:'Inter',Arial,sans-serif;background:#f0f4f8;min-height:100vh;padding:40px 20px;color:#1a1a2e}
        .page{max-width:780px;margin:0 auto}
        .hero{background:#1a3c5e;border-radius:16px;padding:40px;margin-bottom:24px;display:flex;justify-content:space-between;align-items:center}
        .hero h1{font-size:26px;font-weight:700;color:#fff}
        .hero p{font-size:13px;color:rgba(255,255,255,0.6);margin-top:6px;line-height:1.6}
        .hero-badge{background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.2);border-radius:12px;padding:14px 22px;text-align:center}
        .hero-badge .rx{font-size:34px;font-weight:700;color:#fff;font-style:italic}
        .hero-badge .sub{font-size:10px;color:rgba(255,255,255,0.55);letter-spacing:1.5px;margin-top:3px}
        .pill{display:inline-flex;align-items:center;gap:6px;background:#dcfce7;border:1px solid #86efac;border-radius:20px;padding:5px 14px;font-size:11px;font-weight:600;color:#166534;margin-top:14px}
        .dot{width:7px;height:7px;border-radius:50%;background:#16a34a}
        .section-title{font-size:11px;font-weight:600;color:#6b7fa3;text-transform:uppercase;letter-spacing:0.8px;margin-bottom:12px}
        .endpoints{display:flex;flex-direction:column;gap:12px;margin-bottom:24px}
        .endpoint-card{background:#fff;border:0.5px solid #dde8f7;border-radius:12px;padding:16px 20px;display:flex;align-items:center;gap:16px;text-decoration:none}
        .method{font-size:10px;font-weight:700;padding:4px 10px;border-radius:6px}
        .get{background:#dcfce7;color:#166534}.post{background:#fff7ed;color:#9a3412}
        .ep-path{font-size:13px;font-weight:600;color:#1a1a2e;font-family:monospace}
        .ep-desc{font-size:11px;color:#6b7fa3;margin-top:2px}
        .seed-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:24px}
        .seed-card{background:#fff;border:0.5px solid #dde8f7;border-radius:12px;padding:16px 20px}
        .seed-id{font-size:18px;font-weight:700;color:#1a3c5e;font-style:italic;margin-bottom:8px}
        .seed-label{font-size:11px;color:#6b7fa3;margin-bottom:2px}
        .seed-val{font-size:13px;font-weight:500;color:#1a1a2e;margin-bottom:6px}
        .seed-links{display:flex;gap:8px;margin-top:10px;padding-top:10px;border-top:0.5px solid #eef2f9}
        .seed-link{font-size:10px;font-weight:600;color:#2563a8;text-decoration:none;background:#eef4ff;border-radius:6px;padding:3px 10px}
        .footer{text-align:center;font-size:10px;color:#a0aec0;margin-top:8px}
      </style></head><body>
      <div class="page">
        <div class="hero">
          <div>
            <h1>Pharmacy Prescription<br/>Integration System</h1>
            <p>University Software Engineering Project<br/>Ruby on Rails · MVC Architecture</p>
            <div class="pill"><div class="dot"></div> Server is running</div>
          </div>
          <div class="hero-badge"><div class="rx">Rx</div><div class="sub">API v1.0</div></div>
        </div>
        <div class="section-title">Available Endpoints</div>
        <div class="endpoints">
          <div class="endpoint-card"><span class="method post">POST</span>
            <div><div class="ep-path">/prescriptions/:id/instructions</div><div class="ep-desc">Story 6 — Add medication dosage instructions to a prescription</div></div>
          </div>
          <a class="endpoint-card" href="/prescriptions/RX-001/print"><span class="method get">GET</span>
            <div><div class="ep-path">/prescriptions/:id/print</div><div class="ep-desc">Story 16 — Generate a printable HTML prescription document</div></div>
          </a>
          <a class="endpoint-card" href="/prescriptions/RX-001/history"><span class="method get">GET</span>
            <div><div class="ep-path">/prescriptions/:id/history</div><div class="ep-desc">Story 19 — View the full status timeline for a prescription</div></div>
          </a>
        </div>
        <div class="section-title">Seed Prescriptions</div>
        <div class="seed-grid">
          <div class="seed-card">
            <div class="seed-id">Rx RX-001</div>
            <div class="seed-label">Patient</div><div class="seed-val">John Smith</div>
            <div class="seed-label">Medication</div><div class="seed-val">Amoxicillin</div>
            <div class="seed-label">Status</div><div class="seed-val">Pending</div>
            <div class="seed-links"><a class="seed-link" href="/prescriptions/RX-001/print">Print</a><a class="seed-link" href="/prescriptions/RX-001/history">History</a></div>
          </div>
          <div class="seed-card">
            <div class="seed-id">Rx RX-002</div>
            <div class="seed-label">Patient</div><div class="seed-val">Maria Gonzalez</div>
            <div class="seed-label">Medication</div><div class="seed-val">Metformin</div>
            <div class="seed-label">Status</div><div class="seed-val">Sent to Pharmacy</div>
            <div class="seed-links"><a class="seed-link" href="/prescriptions/RX-002/print">Print</a><a class="seed-link" href="/prescriptions/RX-002/history">History</a></div>
          </div>
        </div>
        <div class="footer">Pharmacy Prescription Integration System &nbsp;·&nbsp; CSC 411 Senior Project &nbsp;·&nbsp; #{Time.now.year}</div>
      </div></body></html>
    HTML
    render html: html.html_safe
  end

end