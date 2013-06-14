module Listings
  module ConfigurationMethods
    extend ActiveSupport::Concern

    included do
      attr_accessor :page
      attr_accessor :scope
      attr_accessor :items

      def page_size
        self.class.page_size
      end

      def scopes
        self.class.scopes
      end

      def model_class
        self.class.model_class
      end

      def columns
        self.class.columns
      end
    end

    module ClassMethods
      attr_accessor :page_size
      attr_accessor :model_class

      def paginates_per(val)
        @page_size = val
      end

      def scope(name, props = {})
        scopes << ScopeDescriptor.new(name, props)
      end

      def scopes
        @scopes ||= []
      end

      def model(val)
        @model_class = val
      end

      def columns
        @columns ||= []
      end

      def column(name = '', &proc)
        columns << ColumnDescriptor.new(self, name, proc)
      end

    end
  end

  module ViewHelperMethods
    extend ActiveSupport::Concern

    included do
      def is_active_scope(scope)
        self.scope.name == scope.name
      end

      def url_for_scope(scope)
        params = view_context.params.merge(param_scope => scope.name)
        params.delete param_page
        view_context.url_for(params)
      end

      def no_data_message
        I18n.t 'listings.no_data', kind: self.model_class.model_name.human.downcase.pluralize
      end
    end
  end

  class Base
    include Listings::ConfigurationMethods
    include Listings::ViewHelperMethods
    attr_accessor :view_context

    def param_scope; :scope; end
    def param_page; :page; end

    def filter_items(params, items)
      self.page = params[param_page] || 1
      self.scope = scope_by_name(params[param_scope])
      items = scope.apply(items) unless scope.nil?

      items.page(page).per(page_size)
    end

    def query_items(params)
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

  class ScopeDescriptor
    attr_accessor :name

    def initialize(name, props = {})
      props.reverse_merge! default: false

      @name = name
      @props = props
    end

    def human_name
      name.to_s.humanize
    end

    def is_default?
      @props[:default]
    end

    def apply(items)
      if name == :all
        items
      else
        items.send(name)
      end
    end
  end

  class ColumnDescriptor
    attr_reader :name

    def initialize(listing_class, name, proc)
      @listing_class = listing_class
      @name = name
      @proc = proc
    end

    def value_for(listing, model)
      if @proc
        listing.instance_exec model, &@proc
      else
        model.send(name)
      end
    end

    def human_name
      if name.is_a? Symbol
        @listing_class.model_class.human_attribute_name(name)
      else
        name
      end
    end
  end
end