class PrescriptionValidationService
  def initialize(params)
    @params = params
    @errors = []
  end

  def valid?
    validate_required_fields
    validate_dosage_format
    validate_medication_name
    validate_quantity
    @errors.empty?
  end

  def errors
    @errors
  end

  private

  def validate_required_fields
    %i[medication dosage frequency quantity patient_id provider_id pharmacy_id].each do |field|
      @errors << "#{field.to_s.humanize} is required." if @params[field].blank?
    end
  end

  def validate_dosage_format
    return if @params[:dosage].blank?
    unless @params[:dosage].match?(/\d+\s*[a-zA-Z]+/)
      @errors << "Dosage must include a numeric value and a unit (e.g. 500mg, 10ml)."
    end
  end

  def validate_medication_name
    return if @params[:medication].blank?
    @errors << "Medication name must be at least 2 characters." if @params[:medication].length < 2
  end

  def validate_quantity
    return if @params[:quantity].blank?
    unless @params[:quantity].to_s.match?(/\A\d+\z/) && @params[:quantity].to_i > 0
      @errors << "Quantity must be a positive whole number."
    end
  end
end
