module Listings::Sources
  class ObjectDataSource < DataSource
    def initialize(items)
      @items = items
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
end
