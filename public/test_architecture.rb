# --- ARCHITECT'S MOCK DATA ---
# We create these "Dummy" classes so the code has something to talk to.
class RetailPharmacyService
  def initialize(rx); @rx = rx; end
  def send_data; puts "✅ SUCCESS: Data sent to RETAIL system for #{@rx.id}"; end
end

class MailOrderService
  def initialize(rx); @rx = rx; end
  def send_data; puts "✅ SUCCESS: Data sent to MAIL-ORDER system for #{@rx.id}"; end
end

# A simple object to act like a real Prescription
class MockPrescription
  attr_accessor :id, :pharmacy_type
  def initialize(id, type); @id = id; @pharmacy_type = type; end
end

# --- THE TEST RUN ---
puts "--- STARTING ARCHITECTURE INTEGRATION TEST ---"

# Test 1: Retail
rx1 = MockPrescription.new("RX-101", "retail")
PharmacyAdapter.dispatch(rx1)

# Test 2: Mail Order
rx2 = MockPrescription.new("RX-202", "mail_order")
PharmacyAdapter.dispatch(rx2)

puts "--- TEST COMPLETE ---"
