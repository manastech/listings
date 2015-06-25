module Listings
  # = Helpers
  module ActionViewExtensions
    def render_listing(key, options = {})
      options.reverse_merge! :params => {}
      params_for_listing = {:listing => key}.merge(params).merge(options[:params]).with_indifferent_access
      listing = prepare_listing(params_for_listing, self)
      res = listings_partial_render 'listing', listing
      Kaminari::Helpers::Tag.paginate_with_listings(nil)
      res
    end
    end

    def listings_partial_render(view, listing, options = {})
      prefix = [
        "listings/#{listing.name}",
        "listings/#{listing.theme}",
        "listings"
      ].select { |p| lookup_context.exists?("#{p}/_#{view}") }.first

      render "#{prefix}/#{view}", options.merge(listing: listing)
    end

    def prepare_listing(params, view_context, paging = true)
      params.delete :controller
      params.delete :action

      Kaminari::Helpers::Tag.paginate_with_listings(view_context.listings)

      listing_class = lookup_listing_class(params[:listing])
      listing_class.new.tap do |listing|
        _prepare_view_context view_context
        listing.view_context = view_context
        if !paging
          listing.page_size = :none
        end
        listing.query_items(params)
      end
    end

    def lookup_listing_class(name)
      "#{name}_listing".classify.constantize
    end

    def _prepare_view_context(view_context)
      # forward methods from this view context to main app if they are not found
      view_context.class.send(:define_method, 'method_missing') do |m, *args, &block|
        view_context.main_app.send(m, *args, &block)
      end
    end
  end
end
