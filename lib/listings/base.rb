require 'listings/configuration_methods'
require 'listings/view_helper_methods'
require 'csv'

module Listings
  class Base
    include Listings::ConfigurationMethods
    include Listings::ViewHelperMethods
    include ERB::Util # html_escape methods are private in the view_context
                      # so they need to be included in order to be available

    attr_accessor :view_context
    attr_accessor :params

    def initialize
      @page_size = self.class.page_size
    end

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

      items = scope.apply(self, items) unless scope.nil?

      if search.present? && self.searchable?
        criteria = []
        values = []
        self.columns.select(&:searchable?).each do |col|
          criteria << "#{model_class.table_name}.#{col.name} like ?"
          values << "%#{search}%"
        end
        items = items.where(criteria.join(' or '), *values)
      end

      if page_size
        items = items.page(page).per(page_size)
      end

      items
    end

    def query_items(params)
      @params = params
      items = self.model_class
      @has_active_model_source = items.respond_to? :human_attribute_name

      if items.is_a?(Array) && page_size
        items = Kaminari.paginate_array(items)
      end

      self.items = filter_items(self.scoped_params, items)
    end

    def has_active_model_source?
      @has_active_model_source
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
      self.columns.any? { |col| col.searchable?(self) }
    end

    def url
      view_context.listings.listing_full_path(self.name, self.params)
    end

    def format
      (params[:format] || :html).to_sym
    end

    def to_array
      data = []

      data << self.columns.map { |c| c.human_name(self) }

      self.items.each do |item|
        row = []
        self.columns.each do |col|
          row << self.value_for(col, item)
        end
        data << row
      end

      data
    end

    def to_csv
      CSV.generate do |csv|
        self.to_array.each do |row|
          csv << row
        end
      end
    end

    def method_missing(m, *args, &block)
      delegated_to = view_context.respond_to?(m) ? view_context : view_context.main_app
      delegated_to.send(m, *args, block)
    end
  end
end
