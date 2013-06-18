module Listings
  class ColumnDescriptor
    attr_reader :name

    def initialize(listing_class, name, proc)
      @listing_class = listing_class
      @name = name
      @proc = proc
    end

    def value_for(listing, model)
      if @proc
        listing.instance_exec model, &@proc
      else
        model.send(name)
      end
    end

    def human_name
      if name.is_a? Symbol
        @listing_class.model_class.human_attribute_name(name)
      else
        name
      end
    end
  end
end