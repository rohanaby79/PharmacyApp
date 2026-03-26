### **2. Your "Architect" Code**
Architects often create **"Design Patterns."** I've updated the code from before to be an "Adapter Pattern"—this allows your app to talk to *any* pharmacy (CVS, Walgreens, etc.) using the same logic.

**File: `app/models/pharmacy_adapter.rb`**
```ruby
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
