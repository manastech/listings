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
        _prepare_view_context view_context
        listing.view_context = view_context
        if !paging
          listing.page_size = :none
        end
        listing.query_items(params)
      end
    end

    def _prepare_view_context(view_context)
      # forward methods from this view context to main app if they are not found
      view_context.class.send(:define_method, 'method_missing') do |m, *args, &block|
        view_context.main_app.send(m, *args, &block)
      end
    end
  end
end
