module Listings
  class FilterView
    attr_reader :field

    def initialize(listing, filter_description)
      @listing = listing
      @filter_description = filter_description
      @field = listing.data_source.build_field(filter_description.path)
    end

    def human_name
      key
    end

    def key
      @field.key
    end

    def values
      @values ||= @listing.data_source.values_for_filter(field)
    end
  end
end
