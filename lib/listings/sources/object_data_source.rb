module Listings::Sources
  class ObjectDataSource < DataSource
    def initialize(items)
      @items = items
      @items_for_filter = items
    end

    def items
      @items
    end

    def paginate(page, page_size)
      @items = Kaminari.paginate_array(@items)
      @items = @items.page(page).per(page_size)
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
      path = self.sanitaize_path(path)
      unless path.is_a?(Array)
        path = [path]
      end
      ObjectField.new(path, self)
    end
  end

  class DataSource
    class << self
      def for_with_object(model)
        ObjectDataSource.new(model)
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
        # TODO deal with nils
        if obj.is_a?(Hash) && obj.key?(attribute)
          obj[attribute]
        else
          begin
            obj.send attribute
          rescue
            binding.pry
          end
        end
      end
    end
  end
end
