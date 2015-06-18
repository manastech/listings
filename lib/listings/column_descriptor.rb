module Listings
  class ColumnDescriptor
    attr_reader :name
    attr_reader :props
    attr_reader :proc

    def initialize(listing_class, name, props = {}, proc)
      @listing_class = listing_class
      @name = name
      @props = props.reverse_merge! searchable: false, sortable: true
      @proc = proc
    end

    def human_name(listing)
      return '' if name.blank?

      fallback = if is_model_column?(listing)
        listing.model_class.human_attribute_name(name)
      else
        name
      end
      I18n.t("listings.headers.#{listing.name}.#{name}", default: fallback)
    end

    def searchable?(listing)
      @props[:searchable] && is_model_column?(listing)
    end

    def sortable?
      s = @props[:sortable]
      if sortable_property_is_expression?
        true # s is the expression that should be used for sorting
      else
        s # s is Boolean
      end
    end

    def sortable_property_is_expression?
      s = @props[:sortable]
      !(!!s == s)
    end

    def is_model_column?(listing)
      name.is_a?(Symbol) && listing.has_active_model_source?
    end
  end
end
