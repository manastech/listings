module Listings::Sources
  class ObjectDataSource < DataSource
    def initialize(items)
      @items = items
      @items_for_filter = items
    end

    def items
      @items
    end

    def transform_items
      @items = yield @items
    end

    def paginate(page, page_size)
      @items = Kaminari.paginate_array(@items).page(page).per(page_size)
    end

    def scope
      @items = yield @items
      @items_for_filter = yield @items_for_filter
    end

    def sort_with_direction(field, direction)
      @items = @items.sort do |a, b|
        b, a = a, b if direction == DESC
        field.value_for(a) <=> field.value_for(b)
      end
    end

    def values_for_filter(field)
      @items_for_filter.map { |o| field.value_for(o) }.uniq.reject(&:nil?).sort
    end

    def search(fields, value)
      @items = @items.select do |item|
        fields.any? do |field|
          field.value_for(item).try { |o| o.include?(value) }
        end
      end
    end

    def filter(field, value)
      @items = @items.select do |item|
        field.value_for(item) == value
      end
    end

    def build_field(path)
      path = self.class.sanitaize_path(path)
      unless path.is_a?(Array)
        path = [path]
      end
      ObjectField.new(path, self)
    end
  end

  class DataSource
    class << self
      def for_with_object(model)
        if model.is_a?(Array) # TODO Enumerable
          ObjectDataSource.new(model)
        else
          for_without_object(model)
        end
      end

      alias_method_chain :for, :object
    end
  end

  class ObjectField < Field
    def initialize(path, data_source)
      super(data_source)
      @path = path
    end

    def value_for(item)
      @path.inject(item) do |obj, attribute|
        if obj.nil?
          nil
        elsif obj.is_a?(Hash) && obj.key?(attribute)
          obj[attribute]
        else
          obj.send attribute
        end
      end
    end

    def key
      @path.join('_')
    end

    def human_name
      @path.join(' ')
    end
  end
end
