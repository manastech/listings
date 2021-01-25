module Listings
  class ListingsController < ActionController::Base
    include ActionViewExtensions

    def full
      @listing = prepare_listing params, view_context
      render 'listings/full'
    ensure
      Kaminari::Helpers::Tag.paginate_with_listings(nil)
    end

    def content
      @listing = prepare_listing params, view_context
      render 'listings/content'
    ensure
      Kaminari::Helpers::Tag.paginate_with_listings(nil)
    end

    def export
      @listing = prepare_listing params, view_context, false

      respond_to do |format|
        format.csv { @listing.send_csv(self) }
        format.xls do
          headers["Content-Disposition"] = "attachment; filename=\"#{@listing.export_filename(:xls)}\""
          render 'listings/export'
        end
      end
    ensure
      Kaminari::Helpers::Tag.paginate_with_listings(nil)
    end

  end
end
