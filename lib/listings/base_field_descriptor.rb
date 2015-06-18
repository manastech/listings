module Listings
  class BaseFieldDescriptor
    attr_reader :path
    attr_reader :props
    attr_reader :proc

    def initialize(path, props, proc)
      @path = path
      @props = props
      @proc = proc
    end

    def build_field(listing)
      listing.data_source.build_field(path)
    end

    def is_field?
      !path.nil? && !path.is_a?(String)
    end
  end
end
