module Listings
  class ListingsController < ActionController::Base
    include ActionViewExtensions

    def full
      @listing = prepare_listing params, view_context
      render 'listings/full'
    end

    def content
      @listing = prepare_listing params, view_context
      render 'listings/content'
    end

    def export
      @listing = prepare_listing params, view_context, false

      respond_to do |format|
        format.csv { send_data @listing.to_csv, filename: "#{params[:listing]}.csv" }
      end
    end

  end
end
