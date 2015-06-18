module Listings::Sources
  class ActiveRecordDataSource < DataSource
    attr_reader :model_instance

    def initialize(model)
      @items = model
      if model.is_a?(ActiveRecord::Relation)
        @items_for_filter = model.clone
        @model_instance = model.klass.new
      else
        @items_for_filter = model
        @model_instance = model.new
      end
    end

    def connection
      model_instance.class.connection
    end

    def items
      if @items.is_a?(Class)
        if Rails::VERSION::MAJOR == 3
          @items.scoped
        else
          @items.all
        end
      else
        @items
      end
    end

    def scope
      @items = yield @items
      @items_for_filter = yield @items_for_filter
    end

    def sort_with_direction(field, direction)
      @items = field.sort @items, direction
    end

    def values_for_filter(field)
      @items_for_filter.reorder(field.query_column).pluck("distinct #{field.query_column}").reject(&:nil?)
    end

    def search(fields, value)
      criteria = []
      values = []
      fields.each do |field|
        criteria << "#{field.query_column} like ?"
        values << "%#{value}%"
      end
      @items = @items.where(criteria.join(' or '), *values)
    end

    def filter(field, value)
      @items = @items.where("#{field.query_column} = ?", value)
    end

    def paginate(page, page_size)
      @items = @items.page(page).per(page_size)
    end

    def joins(relation)
      @items = @items.eager_load(relation)
      @items_for_filter = @items_for_filter.joins(relation)
    end

    def build_field(path)
      path = self.class.sanitaize_path(path)
      if path.is_a?(Array)
        ActiveRecordAssociationField.new(path, self)
      else
        ActiveRecordField.new(path, self)
      end
    end
  end

  class DataSource
    class << self
      def for_with_active_record(model)
        if (model.is_a?(Class) && model.ancestors.include?(ActiveRecord::Base)) || model.is_a?(ActiveRecord::Relation)
          ActiveRecordDataSource.new(model)
        else
          for_without_active_record(model)
        end
      end

      alias_method_chain :for, :active_record
    end
  end

  class ActiveRecordField < Field
    delegate :connection, to: :data_source
    delegate :quote_table_name, :quote_column_name, to: :connection

    def initialize(attribute_name, data_source)
      super(data_source)
      @attribute_name = attribute_name
    end

    def value_for(item)
      item.send @attribute_name
    end

    def query_column
      "#{quote_table_name(data_source.items.table_name)}.#{quote_column_name(@attribute_name)}"
    end

    def sort(items, direction)
      items.reorder("#{query_column} #{direction}")
    end

    def key
      @attribute_name.to_s
    end

    def human_name
      data_source.model_instance.class.human_attribute_name(@attribute_name)
    end
  end

  class ActiveRecordAssociationField < Field
    delegate :connection, to: :data_source
    delegate :quote_table_name, :quote_column_name, to: :connection

    def initialize(path, data_source)
      super(data_source)
      @path = path

      data_source.joins(path[0])
    end

    def value_for(item)
      result = item
      @path.each do |attribute_name|
        result = result.try { |o| o.send(attribute_name) }
      end

      result
    end

    def query_column
      association = data_source.model_instance.association(@path[0])
      "#{quote_table_name(association.reflection.table_name)}.#{quote_column_name(@path[1])}"
    end

    def sort(items, direction)
      items.reorder("#{query_column} #{direction}")
    end

    def key
      @path.join('_')
    end

    def human_name
      @path.join(' ').titleize
    end
  end
end
