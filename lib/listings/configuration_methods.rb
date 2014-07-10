require 'listings/scope_descriptor'
require 'listings/column_descriptor'
require 'listings/column_view'

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
        @columns ||= self.class.columns.map do |cd|
          ColumnView.new(self, cd)
        end
      end

      def export_formats
        self.class.export_formats
      end

      def is_sortable?
        opt = self.class.sortable_options
        if opt.nil?
          true
        else
          if opt.length == 1 && !!opt.first == opt.first
            opt.first
          else
            true
          end
        end
      end

      def table_css_class
        self.class.table_css_class
      end

      def row_style_for(item)
        self.class.row_style_applicator.call item if self.class.row_style_applicator
      end
    end

    module ClassMethods
      attr_accessor :page_size
      attr_reader :sortable_options
      attr_accessor :table_css_class
      attr_reader :row_style_applicator

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

      def selectable #(column = :id)
        @selectable = true
        # @column_identifier = column
      end

      def selectable?
        @selectable == true
      end

      def export_formats
        @export ||= []
      end

      def export(*formats)
        formats.each do |f|
          export_formats << f
        end
      end

      def sortable(*options)
        @sortable_options = options
      end

      def css_class(value)
        @table_css_class = value
      end

      def row_style(&proc)
        @row_style_applicator = proc
      end
    end
  end
end
