module Api
  class PharmaciesController < ApplicationController
    def index
      zip = params[:zip]
      radius = params[:radius] || 5

      if zip.blank?
        render json: { error: "ZIP code required" }, status: :bad_request
        return
      end

      pharmacies = PharmacyOsmService.new(zip, radius).search
      render json: pharmacies
    end
  end
end