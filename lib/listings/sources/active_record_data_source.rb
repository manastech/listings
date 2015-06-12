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
