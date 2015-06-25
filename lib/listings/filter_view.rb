module Listings
  class FilterView < BaseFieldView
    def initialize(listing, filter_description)
      super
    end

    def values
      @values ||= listing.data_source.values_for_filter(field)
    end

    def value_for(value)
      if @field_description.proc
        listing.instance_exec value, &@field_description.proc
      else
        value
      end
    end

    def render?
      @field_description.props.fetch(:render, true)
    end

    def apply_filter(value)
      listing.data_source.filter(field, value)
    end
  end
end
