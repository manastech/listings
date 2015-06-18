module Listings::Sources
  class DataSource
    DESC = 'desc'
    ASC = 'asc'

    # returns items for the data source
    # if +paginate+ is called, items will return just the current page
    def items
    end

    # applies filter to the items
    # scope will be called with a block with the ongoing items
    # the result of the block is used as the narrowed items
    def scope
    end

    # applies a human friendly search to items among multiple fields
    def search(fields, value)
    end

    # applies exact match filtering among specified field
    def filter(field, value)
    end

    # applies sorting with specified direction to items
    # subclasses should implement +sort_with_direction+ in order to leave
    # default direction logic in +DataSource+
    def sort(field, direction = ASC)
      sort_with_direction(field, direction)
    end

    # returns all values of field
    # usually calling +search+/+filter+/+sort+/+paginate+ should not affect the results.
    # calling +scope+ should affect the results.
    def values_for_filter(field)
    end

    # apply pagination filter to +items+
    # items of the selected page can be obtained through +items+
    def paginate(page, page_size)
    end

    # returns a +Field+ for the specified options
    def build_field(path)
    end

    def self.for(model)
      raise "Unable to create datasource for #{model}"
    end

    def self.sanitaize_path(path)
      if path.is_a?(Array)
        path
      elsif path.is_a?(Hash) && path.size == 1
        path.to_a.first
      else
        path
      end
    end
  end

  class Field
    attr_reader :data_source

    def initialize(data_source)
      @data_source = data_source
    end

    # returns this field over the item
    def value_for(item)
    end

    def key
    end
  end
end
