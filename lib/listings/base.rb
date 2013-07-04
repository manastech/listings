require 'listings/configuration_methods'
require 'listings/view_helper_methods'

module Listings
  class Base
    include Listings::ConfigurationMethods
    include Listings::ViewHelperMethods
    include ERB::Util # html_escape methods are private in the view_context
                      # so they need to be included in order to be available

    attr_accessor :view_context
    attr_accessor :params

    def name
      self.class.name.underscore.sub(/_listing$/,'')
    end

    def param_scope; :scope; end
    def param_page; :page; end
    def param_search; :s; end

    def filter_items(params, items)
      self.page = params[param_page] || 1
      self.scope = scope_by_name(params[param_scope])
      self.search = params[param_search]

      items = scope.apply(items) unless scope.nil?

      if search.present? && self.searchable?
        criteria = []
        values = []
        self.columns.select(&:searchable?).each do |col|
          criteria << "#{model_class.table_name}.#{col.name} like ?"
          values << "%#{search}%"
        end
        items = items.where(criteria.join(' or '), *values)
      end

      items.page(page).per(page_size)
    end

    def query_items(params)
      @params = params
      self.items = filter_items(self.scoped_params, self.model_class)
    end

    def scoped_params
      @params.except(:listing, :controller, :action)
    end

    def scope_by_name(name)
      default_scope = scopes.find { |s| s.is_default? }
      selected_scope = scopes.find { |s| s.name == name.try(:to_sym) }
      selected_scope || default_scope
    end

    def value_for(column, item)
      column.value_for(self, item)
    end

    def searchable?
      self.columns.any? &:searchable?
    end

    def method_missing(m, *args, &block)
      delegated_to = view_context.respond_to?(m) ? view_context : view_context.main_app
      delegated_to.send(m, *args, block)
    end
  end
end