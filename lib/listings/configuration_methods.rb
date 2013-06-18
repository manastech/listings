require 'listings/scope_descriptor'
require 'listings/column_descriptor'

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
end