module Listings::Sources
  class ActiveRecordDataSource < DataSource
    attr_reader :model_instance
    delegate :connection, to: :model_instance

    def initialize(model)
      @items = model
      @model_instance = (if model.is_a?(ActiveRecord::Relation)
        model.klass
      else
        model
      end).new
    end

    def items
      if @items.is_a?(Class)
        @items.scoped
      else
        @items
      end
    end

    def scope
      @items = yield @items
    end

    def sort_with_direction(field, direction)
      @items = field.sort @items, direction
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

    def paginate(page, page_size)
      @items = @items.page(page).per(page_size)
    end

    def joins(relation)
      @items = @items.eager_load(relation)
    end

    def build_field(path)
      if path.is_a?(Array)
        ActiveRecordAssociationField.new(path, self)
      elsif path.is_a?(Hash) && path.size == 1
        ActiveRecordAssociationField.new(path.to_a.first, self)
      else
        ActiveRecordField.new(path, self)
      end
    end
  end

  class DataSource
    class << self
      def for_with_active_record(model)
        ActiveRecordDataSource.new(model)
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
        result = result.send attribute_name
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
  end
end
