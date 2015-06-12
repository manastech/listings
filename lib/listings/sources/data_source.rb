module Listings::Sources
  class DataSource
    def self.for(model)
      raise "Unable to create datasource for #{model}"
    end
  end
end
