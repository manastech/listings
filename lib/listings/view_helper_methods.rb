module Listings
  module ViewHelperMethods
    extend ActiveSupport::Concern

    included do
      def is_active_scope(scope)
        self.scope.name == scope.name
      end

      def url_for_scope(scope)
        params = view_context.params.merge(param_scope => scope.name, :listing => self.name)
        params.delete param_page
        params.delete :controller
        params.delete :action
        params = params.with_indifferent_access
        view_context.listings.listing_full_url(params)
      end

      def url_for_format(format)
        params = view_context.params.merge(:format => format, :listing => self.name)
        params.delete param_page
        params.delete :controller
        params.delete :action
        params = params.with_indifferent_access
        view_context.listings.listing_export_url(params)
      end

      def no_data_message
        I18n.t 'listings.no_data', kind: kind
      end

      def export_message
        I18n.t 'listings.export'
      end

      def search_placeholder
        I18n.t 'listings.search_placeholder', kind: kind
      end

      def kind
        model_class.model_name.human.downcase.pluralize
      end
    end
  end
end
