module Listings
  class BaseFieldDescriptor
    attr_reader :path
    attr_reader :props

    def initialize(path, props)
      @path = path
      @props = props
    end

    def build_field(listing)
      listing.data_source.build_field(path)
    end

    def is_field?
      !path.nil? && !path.is_a?(String)
    end
  end
end
