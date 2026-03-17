class PharmacySourceService
  def initialize(zip, radius)
    @zip = zip
    @radius = radius.to_i
  end

  def fetch_pharmacies
    if use_rest?
      fetch_from_rest
    else
      fetch_from_file
    end
  end

  private

  # Toggle REST vs File for testing/demo
  def use_rest?
    true  # switch to false to test file source
  end

  # Simulated REST API fetch
  def fetch_from_rest
    # Normally: HTTP call to external pharmacy service
    # Here: Simulate a few pharmacies
    [
      {
        name: "CVS Pharmacy",
        address: "123 Main St",
        zip: @zip,
        identifier: "CVS001",
        phone_number: "555-111-2222",
        supports_e_rx: true
      },
      {
        name: "Walgreens",
        address: "456 Elm St",
        zip: @zip,
        identifier: "WAL001",
        phone_number: "555-333-4444",
        supports_e_rx: true
      }
    ]
  end

  # Fetch from approved file
  def fetch_from_file
    file_path = Rails.root.join("data/pharmacies.json")
    all_pharmacies = JSON.parse(File.read(file_path), symbolize_names: true)
    all_pharmacies.select { |p| p[:zip] == @zip }
  end
end