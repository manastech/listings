module Listings
  class FilterDescriptor
    attr_reader :path

    def initialize(listing_class, path)
      @listing_class = listing_class
      @path = path
    end
  end
end
