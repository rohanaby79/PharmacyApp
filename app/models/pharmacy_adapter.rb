class PharmacyAdapter
  def self.dispatch(prescription)
    case prescription.pharmacy_type.downcase
    when 'retail'
      service = RetailPharmacyService.new(prescription)
      service.send_data
    when 'mail_order'
      service = MailOrderService.new(prescription)
      service.send_data
    else
      puts "❌ ERROR: Unknown pharmacy type: #{prescription.pharmacy_type}"
    end
  end
end

# Final Verification: March 31st, 2026