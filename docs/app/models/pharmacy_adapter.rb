class PharmacyAdapter
  # Bogdan's Architecture: The "Adapter Pattern"
  # This allows the app to stay organized regardless of which pharmacy we use.

  def self.dispatch(prescription)
    case prescription.pharmacy_type
    when 'retail'
      RetailPharmacyService.new(prescription).send_data
    when 'mail_order'
      MailOrderService.new(prescription).send_data
    else
      raise "Unknown Architecture Pathway"
    end
  end
end
