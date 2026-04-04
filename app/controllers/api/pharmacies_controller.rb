# app/controllers/api/pharmacies_controller.rb
# Epic 1 — Pharmacy Discovery & Selection
module Api
  class PharmaciesController < ApplicationController
    before_action :authenticate_doctor!

    # GET /api/pharmacies?zip=74104&radius=5
    # Returns pharmacies from DB first, then falls back to OpenStreetMap data.
    def index
      zip    = params[:zip].presence
      radius = (params[:radius] || 5).to_f

      if zip.blank?
        return render json: { error: "ZIP code is required." }, status: :bad_request
      end

      # 1. Try DB pharmacies first (seeded from data/pharmacies.json or admin-added)
      db_pharmacies = Pharmacy.search_by_zip(zip).map { |p| pharmacy_json(p) }

      # 2. Augment with live OSM data if available
      osm_pharmacies = fetch_osm_pharmacies(zip, radius)

      # Merge: prefer DB records, append OSM-only results
      db_ids  = db_pharmacies.map { |p| p[:identifier] }.to_set
      extras  = osm_pharmacies.reject { |p| db_ids.include?(p[:identifier]) }
      results = db_pharmacies + extras

      render json: results, status: :ok
    end

    private

    def pharmacy_json(p)
      {
        id:            p.id,
        identifier:    p.identifier,
        name:          p.name,
        address:       p.address,
        zip:           p.zip,
        phone:         p.phone_number,
        supports_e_rx: p.supports_e_rx,
        pharmacy_type: p.pharmacy_type
      }
    end

    def fetch_osm_pharmacies(zip, radius)
      PharmacyOsmService.new(zip, radius).search
    rescue => e
      Rails.logger.warn "[PharmaciesController] OSM lookup failed: #{e.message}"
      []
    end
  end
end
