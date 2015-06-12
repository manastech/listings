module Listings::Sources
  class ActiveRecordDataSource < DataSource
    def initialize(model)
      @model = model
    end

    def items
      @model
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
end
