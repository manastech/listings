module Listings
  class ColumnDescriptor
    attr_reader :name

    def initialize(listing_class, name, props = {}, proc)
      @listing_class = listing_class
      @name = name
      @props = props.reverse_merge! searchable: false
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
      if is_model_column?
        @listing_class.model_class.human_attribute_name(name)
      else
        name
      end
    end

    def searchable?
      @props[:searchable] && is_model_column?
    end

    def is_model_column?
      name.is_a? Symbol
    end
  end
end