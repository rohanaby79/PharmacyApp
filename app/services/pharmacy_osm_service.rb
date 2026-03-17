class PharmacyOsmService
  require 'net/http'
  require 'uri'
  require 'json'

  def initialize(zip, radius_km)
    @zip = zip
    @radius = radius_km.to_f
  end

  def search
    coords = zip_to_coordinates(@zip)
    return [] unless coords
    pharmacies_near(coords[:lat], coords[:lon], @radius)
  end

  private

  def zip_to_coordinates(zip)
    url = URI("https://nominatim.openstreetmap.org/search?postalcode=#{zip}&country=USA&format=json")
    req = Net::HTTP::Get.new(url)
    req["User-Agent"] = "YourAppName - Rails Demo" # required by OSM
    res = Net::HTTP.start(url.hostname, url.port, use_ssl: true) { |http| http.request(req) }
    results = JSON.parse(res.body)
    return nil if results.empty?
    { lat: results.first['lat'].to_f, lon: results.first['lon'].to_f }
  end

  def pharmacies_near(lat, lon, radius_km)
    radius_m = (radius_km * 1000).to_i
    query = <<~OVERPASS
      [out:json];
      node
        ["amenity"="pharmacy"]
        (around:#{radius_m},#{lat},#{lon});
      out;
    OVERPASS

    url = URI("https://overpass-api.de/api/interpreter")
    res = Net::HTTP.post(url, query)
    data = JSON.parse(res.body)
    data["elements"]
  .select { |el| el["tags"]["addr:street"].present? || el["tags"]["addr:full"].present? }
  .map do |el|
    {
      id: el["id"],  # unique identifier
      name: el["tags"]["name"] || "Unknown Pharmacy",
      lat: el["lat"],
      lon: el["lon"],
      address: el["tags"]["addr:street"] || el["tags"]["addr:full"]
    }
end
  end
end