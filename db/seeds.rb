# db/seeds.rb — Seed a test doctor and the pharmacies from data/pharmacies.json

# ── Test Doctor ────────────────────────────────────────────────────────────────
unless Doctor.exists?(email: "test@hospital.com")
  Doctor.create!(
    name:            "Dr. Jane Smith",
    email:           "test@hospital.com",
    password:        "password123",
    license_number:  "MD-12345",
    active:          true
  )
  puts "✅ Seeded test doctor: test@hospital.com / password123"
end

# ── Pharmacies from JSON file ──────────────────────────────────────────────────
json_path = Rails.root.join("data", "pharmacies.json")
if File.exist?(json_path)
  pharmacies = JSON.parse(File.read(json_path))
  pharmacies.each do |p|
    next if Pharmacy.exists?(identifier: p["identifier"])
    Pharmacy.create!(
      name:          p["name"],
      identifier:    p["identifier"],
      address:       p["address"],
      zip:           p["zip"],
      phone_number:  p["phone_number"],
      supports_e_rx: p.fetch("supports_e_rx", true),
      pharmacy_type: p.fetch("pharmacy_type", "retail")
    )
  end
  puts "✅ Seeded #{Pharmacy.count} pharmacies from data/pharmacies.json"
end
