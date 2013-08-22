module Listings
  # = Helpers
  module ActionViewExtensions
    def render_listing(key, options = {})
      options.reverse_merge! :params => {}
      params_for_listing = {:listing => key}.merge(params).merge(options[:params]).with_indifferent_access
      listing = prepare_listing(params_for_listing, self)
      render :partial => 'listings/listing', :locals => { :listing => listing }
    end

    def prepare_listing(params, view_context, paging = true)
      params.delete :controller
      params.delete :action

      Kaminari::Helpers::Tag.listings = view_context.listings

      listing_class = "#{params[:listing]}_listing".classify.constantize
      listing_class.new.tap do |listing|
        listing.view_context = view_context
        if !paging
          listing.page_size = false
        end
        listing.query_items(params)
      end
    end
  end
end
