module Listings::Sources
  class ActiveRecordDataSource < DataSource
    def initialize(model)
      @items = model
    end

    def items
      @items
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
    def initialize(attribute_name, data_source)
      super(data_source)
      @attribute_name = attribute_name
    end

    def value_for(item)
      item.send @attribute_name
    end
  end

  class ActiveRecordAssociationField < Field
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
  end
end
