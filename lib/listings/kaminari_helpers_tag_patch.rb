module Kaminari
  module Helpers
    class Tag

      def self.listings=(val)
        @@listings=val
      end

      # patch kaminari helpers
      # passing options of mountable engine routes seems to not be working
      def page_url_for(page)
        @params.delete :page
        params = {@param_name => page}.merge(@params).with_indifferent_access
        params.delete :controller
        params.delete :action
        @@listings.listing_content_url(params)
      end
    end
  end
end
