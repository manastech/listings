module Listings
  class ColumnDescriptor
    attr_reader :name
    attr_reader :props

    def initialize(listing_class, name, props = {}, proc)
      @listing_class = listing_class
      @name = name
      @props = props.reverse_merge! searchable: false, sortable: true
      @proc = proc
    end

    def value_for(listing, model)
      if @proc
        listing.instance_exec model, &@proc
      elsif model.is_a?(Hash)
        model[name]
      else
        model.send(name)
      end
    end

    def human_name(listing)
      if is_model_column?(listing)
        listing.model_class.human_attribute_name(name)
      else
        name
      end
    end

    def searchable?(listing)
      @props[:searchable] && is_model_column?(listing)
    end

    def sortable?
      s = @props[:sortable]
      if !!s == s
        s # s is Boolean
      else
        true # s is the expression that should be used for sorting
      end
    end

    def is_model_column?(listing)
      name.is_a?(Symbol) && listing.has_active_model_source?
    end
  end
end
