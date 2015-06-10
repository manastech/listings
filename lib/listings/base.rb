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

    attr_accessor :search_criteria
    attr_accessor :search_filters

    def initialize
      @page_size = self.class.page_size
    end

    def name
      self.class.name.underscore.sub(/_listing$/,'')
    end

    def param_scope; :scope; end
    def param_page; :page; end
    def param_search; :s; end
    def param_sort_by; :sort_by; end
    def param_sort_direction; :sort_d; end

    def parse_search
      if !filterable?
        # if it is not filterable, all the search is used as search criteria
        self.search_criteria = self.search
        self.search_filters = {}
      else
        # otherwise parse the search stripping out allowed filterable fields
        self.search_filters, self.search_criteria = parse_filter(self.search, self.filters)
      end
    end

    def parse_filter(text, filter_keys)
      filters = {}
      filter_keys.each do |key|
        text = collect_filter text, key, filters
      end

      return filters, text
    end

    def collect_filter(text, filter, filters_hash)
      ["#{filter}:\s*(\\w+)",
       "#{filter}:\s*\"([^\"]+)\"",
       "#{filter}:\s*\'([^\']+)\'"].each do |pattern|
        m = Regexp.new(pattern, Regexp::IGNORECASE).match(text)
        if m
          filters_hash[filter] = m[1]
          return "#{m.pre_match.strip} #{m.post_match.strip}".strip
        end
      end

      return text
    end

    def filter_items(params, items)
      self.page = params[param_page] || 1
      self.scope = scope_by_name(params[param_scope])
      self.search = params[param_search]
      parse_search

      items = paginatable(scope.apply(self, items)) unless scope.nil?

      if search_criteria.present? && self.searchable?
        criteria = []
        values = []
        self.columns.select(&:searchable?).each do |col|
          criteria << "#{model_class.table_name}.#{col.name} like ?"
          values << "%#{search_criteria}%"
        end
        items = items.where(criteria.join(' or '), *values)
      end

      if filterable?
        # pluck filters values before applying filters/pagination/sorting
        self.filter_values = {}
        filters.each do |v|
          self.filter_values[v] = items.pluck("distinct #{v}").reject(&:nil?)
        end

        self.search_filters.each do |key, filter_value|
          items = items.where("#{model_class.table_name}.#{key} = ?", filter_value)
        end
      end

      if params.include?(param_sort_by)
        sort_col = column_with_name(params[param_sort_by])
        sort_col.sort = params[param_sort_direction]
        items = items.reorder("#{sort_col.sort_by} #{params[param_sort_direction]}")
      end

      if paginated?
        items = items.page(page).per(page_size)
      end

      if items.is_a?(Class)
        items = items.all
      end

      items
    end

    def query_items(params)
      @params = params
      items = self.model_class
      @has_active_model_source = items.respond_to? :human_attribute_name

      self.items = filter_items(self.scoped_params, paginatable(items))
    end

    def paginatable(array_or_model)
      if array_or_model.is_a?(Array) && paginated? && !array_or_model.respond_to?(:page)
        Kaminari.paginate_array(array_or_model)
      else
        array_or_model
      end
    end

    def has_active_model_source?
      @has_active_model_source
    end

    def selectable?
      self.class.selectable?
    end

    def paginated?
      self.page_size != :none
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

    def column_with_name(name)
      self.columns.find { |c| c.name.to_s == name.to_s }
    end

    def searchable?
      self.columns.any? &:searchable?
    end

    def filterable?
      !self.filters.empty?
    end

    def selectable_id(model)
      model.id
    end

    def url
      view_context.listings.listing_full_path(self.name, self.params)
    end

    def search_data
      { criteria: self.search_criteria, filters: self.search_filters }
    end

    def format
      (params[:format] || :html).to_sym
    end

    def to_array
      data = []

      data << self.columns.map { |c| c.human_name }

      self.items.each do |item|
        row = []
        self.columns.each do |col|
          row << col.value_for(item)
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
      view_context.send(m, *args, &block)
    end

    def kaminari_theme
      case Listings.configuration.theme
      when 'twitter-bootstrap-2'
        'twitter-bootstrap'
      else
        Listings.configuration.theme
      end
    end
  end
end
