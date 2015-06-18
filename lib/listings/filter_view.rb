module Listings
  class FilterView < BaseFieldView
    def initialize(listing, filter_description)
      super
    end

    def values
      @values ||= listing.data_source.values_for_filter(field)
    end
  end
end
