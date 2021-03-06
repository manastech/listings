module Listings
  module ViewHelperMethods
    extend ActiveSupport::Concern

    included do
      def is_active_scope(scope)
        self.scope.name == scope.name
      end

      def url_for_scope(scope)
        view_context.listings.listing_full_url build_params(param_scope => scope.name)
      end

      def url_for_sort(name, direction)
        view_context.listings.listing_full_url build_params(param_sort_by => name, param_sort_direction => direction)
      end

      def url_for_format(format)
        view_context.listings.listing_export_url build_params(:format => format)
      end

      # TODO add url_for_filter that will build the search string

      def build_params(more_params)
        res = _to_unsafe_h(view_context.params).merge(:listing => self.name).merge(_to_unsafe_h(params)).merge(more_params)
        res.delete param_page
        res.delete :controller
        res.delete :action
        _to_unsafe_h(res).with_indifferent_access
      end

      def _to_unsafe_h(hsh)
        if hsh.respond_to?(:to_unsafe_h)
          hsh.to_unsafe_h
        else
          hsh
        end
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
        model_class.model_name.human.downcase.pluralize rescue I18n.t('listings.records')
      end
    end
  end
end
