class DeaVerificationService
  CONTROLLED_SCHEDULES = %w[II III IV V].freeze

  def initialize(provider_id:, dea_number:, dea_schedule:)
    @provider_id  = provider_id
    @dea_number   = dea_number
    @dea_schedule = dea_schedule&.upcase
  end

  def authorized?
    verify[:authorized]
  end

  def verify
    return { authorized: true, message: "Not a controlled substance. No DEA check needed." } unless controlled_substance?
    if @dea_number.blank?
      return { authorized: false, message: "A valid DEA number is required to prescribe Schedule #{@dea_schedule} substances. Please update your provider profile." }
    end
    unless valid_dea_format?
      return { authorized: false, message: "DEA number format is invalid. Expected: 2 letters + 7 digits (e.g. AB1234563)." }
    end
    { authorized: true, message: "DEA verification passed for Schedule #{@dea_schedule}." }
  end

  private

  def controlled_substance?
    CONTROLLED_SCHEDULES.include?(@dea_schedule)
  end

  def valid_dea_format?
    @dea_number.match?(/\A[A-Z]{2}\d{7}\z/)
  end
end
