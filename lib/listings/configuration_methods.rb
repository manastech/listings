require 'listings/scope_descriptor'
require 'listings/base_field_descriptor'
require 'listings/base_field_view'
require 'listings/column_descriptor'
require 'listings/column_view'
require 'listings/filter_descriptor'
require 'listings/filter_view'

module Listings
  module ConfigurationMethods
    extend ActiveSupport::Concern

    included do
      attr_accessor :page
      attr_accessor :scope
      attr_accessor :search
      attr_accessor :page_size

      def scopes
        @scopes ||= self.class.process_scopes
      end

      def columns
        @columns ||= self.class.columns.map do |cd|
          ColumnView.new(self, cd)
        end
      end

      def export_formats
        self.class.export_formats
      end

      def sortable?
        opt = self.class.sortable_options
        if opt.nil?
          true
        else
          if opt.length == 1
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

      def layout_options
        self.class.layout_options
      end

      def filters
        @filters ||= self.class.filters.map do |fd|
          FilterView.new(self, fd)
        end
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

      def deferred_scopes(&block)
        scopes << DeferredScopeDescriptor.new(&block)
      end

      def process_scopes
        scopes.each do |scope|
          scope.construct if scope.deferred?
        end
        @scopes = scopes.select{ |s| !s.deferred? }
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

      def column(path = '', props = {}, &proc)
        path, props = fix_path_props(path, props)
        columns << ColumnDescriptor.new(path, props, proc)
      end

      def fix_path_props(path, props)
        if path.is_a?(Hash) && path.size > 1
          props = props.merge(path)
          path = Hash[[path.first]]
          props.except!(path.first.first)
        end

        [path, props]
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

      # call `sortable false` make listing non sorted
      # default is `sortable true`
      def sortable(*options)
        @sortable_options = options
      end

      def css_class(value)
        @table_css_class = value
      end

      def row_style(&proc)
        @row_style_applicator = proc
      end

      def filters
        @filters ||= []
      end

      def filter(path = '', props = {}, &proc)
        path, props = fix_path_props(path, props)
        filters << FilterDescriptor.new(path, props, proc)
      end

      def layout(props = {})
        @layout_options = props
      end

      def layout_options
        (@layout_options || {}).reverse_merge! filters: :side
      end
    end
  end
end
