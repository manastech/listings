require 'listings/configuration_methods'
require 'listings/view_helper_methods'

module Listings
  class Base
    include Listings::ConfigurationMethods
    include Listings::ViewHelperMethods
    attr_accessor :view_context
    attr_accessor :params

    def name
      self.class.name.underscore.sub(/_listing$/,'')
    end

    def param_scope; :scope; end
    def param_page; :page; end

    def filter_items(params, items)
      self.page = params[param_page] || 1
      self.scope = scope_by_name(params[param_scope])
      items = scope.apply(items) unless scope.nil?

      items.page(page).per(page_size)
    end

    def query_items(params)
      @params = params
      self.items = filter_items(params, self.model_class)
    end

    def scope_by_name(name)
      default_scope = scopes.find { |s| s.is_default? }
      selected_scope = scopes.find { |s| s.name == name.try(:to_sym) }
      selected_scope || default_scope
    end

    def value_for(column, item)
      column.value_for(self, item)
    end

    def method_missing(m, *args, &block)
      delegated_to = view_context.respond_to?(m) ? view_context : view_context.main_app
      delegated_to.send(m, *args, block)
    end
  end
end