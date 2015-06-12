module Listings::Sources
  class DataSource

    # returns items for the data source
    # if +paginate+ is called, items will return just the current page
    def items
    end

    # apply pagination filter to +items+
    # items of the selected page can be obtained through +items+
    def paginate(page, page_size)
    end

    def self.for(model)
      raise "Unable to create datasource for #{model}"
    end
  end
end
