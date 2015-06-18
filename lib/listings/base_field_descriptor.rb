module Listings
  class BaseFieldDescriptor
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def build_field(listing)
      listing.data_source.build_field(path)
    end

    def is_field?
      !path.nil? && !path.is_a?(String)
    end
  end
end
