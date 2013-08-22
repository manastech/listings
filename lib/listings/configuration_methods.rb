require 'listings/scope_descriptor'
require 'listings/column_descriptor'

module Listings
  module ConfigurationMethods
    extend ActiveSupport::Concern

    included do
      attr_accessor :page
      attr_accessor :scope
      attr_accessor :items
      attr_accessor :search
      attr_accessor :page_size

      def scopes
        self.class.scopes
      end

      def columns
        self.class.columns
      end

      def export_formats
        self.class.export_formats
      end
    end

    module ClassMethods
      attr_accessor :page_size

      def paginates_per(val)
        @page_size = val
      end

      def scope(*args, &block)
        scopes << ScopeDescriptor.new(*args, &block)
      end

      def scopes
        @scopes ||= []
      end

      def model(model_class = nil, &proc)
        if !model_class.nil?
          self.send(:define_method, 'model_class') do
            model_class
          end
        else
          self.send(:define_method, 'model_class', &proc)
        end
      end

      def columns
        @columns ||= []
      end

      def column(name = '', props = {}, &proc)
        columns << ColumnDescriptor.new(self, name, props, proc)
      end

      def export_formats
        @export ||= []
      end

      def export(*formats)
        formats.each do |f|
          export_formats << f
        end
      end
    end
  end
end
