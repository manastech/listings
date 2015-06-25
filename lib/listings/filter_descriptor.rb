module Listings
  class FilterDescriptor < BaseFieldDescriptor
    def initialize(path, props, proc)
      super
    end

    def build(listing)
      FilterView.new(listing, self)
    end
  end
end
