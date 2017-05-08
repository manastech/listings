module Kaminari
  module Helpers
    class Tag
      def self.paginate_with_listings(val)
        Thread.current[:listings] = val
      end

      def self.listings_to_paginate_with
        Thread.current[:listings]
      end

      alias_method :page_url_for_without_listing, :page_url_for
      # patch kaminari helpers
      # passing options of mountable engine routes seems to not be working
      def page_url_for(page)
        if Kaminari::Helpers::Tag.listings_to_paginate_with
          @params.delete :page
          params = {@param_name => page}.merge(@params).with_indifferent_access
          params.delete :controller
          params.delete :action
          Kaminari::Helpers::Tag.listings_to_paginate_with.listing_content_url(params)
        else
          page_url_for_without_listing(page)
        end
      end
    end
  end
end
