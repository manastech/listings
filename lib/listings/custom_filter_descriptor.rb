module Listings
  class CustomFilterDescriptor
    attr_reader :key
    attr_reader :props
    attr_reader :proc

    def initialize(key, props, proc)
      @key = key
      @props = props
      @proc = proc
    end

    def build(listing)
      CustomFilterView.new(listing, self)
    end

    def apply_filter(value)
      data_source.filter(field, value)
    end
  end
end
