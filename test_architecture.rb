require_relative 'app/models/pharmacy_adapter'

# --- ARCHITECT'S MOCK DATA ---
class RetailPharmacyService
  def initialize(rx); @rx = rx; end
  def send_data; puts "✅ SUCCESS: Data sent to RETAIL system for #{@rx.id}"; end
end

class MailOrderService
  def initialize(rx); @rx = rx; end
  def send_data; puts "✅ SUCCESS: Data sent to MAIL-ORDER system for #{@rx.id}"; end
end

class MockPrescription
  attr_accessor :id, :pharmacy_type
  def initialize(id, type); @id = id; @pharmacy_type = type; end
end

# --- THE TEST RUN ---
puts "--- STARTING ARCHITECTURE INTEGRATION TEST ---"

rx1 = MockPrescription.new("RX-101", "retail")
PharmacyAdapter.dispatch(rx1)

rx2 = MockPrescription.new("RX-202", "mail_order")
PharmacyAdapter.dispatch(rx2)

puts "--- TEST COMPLETE ---"