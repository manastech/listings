module Listings
  class CustomFilterView
    attr_reader :listing
    attr_reader :descriptor

    def initialize(listing, descriptor)
      @listing = listing
      @descriptor = descriptor
    end

    def key
      @descriptor.key
    end

    def render?
      false
    end

    def apply_filter(value)
      listing.data_source.transform_items do |items|
        listing.instance_exec items, value, &@descriptor.proc
      end
    end
  end
end
