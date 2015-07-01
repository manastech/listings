module Listings
  class FilterView < BaseFieldView
    def initialize(listing, filter_description)
      super
    end

    def prepare_values
      values
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

    def apply_filter(value)
      listing.data_source.filter(field, value)
    end

    def render?
      if render_option.is_a?(String)
        true
      else
        render_option
      end
    end

    def partial_name
      if render_option.is_a?(String)
        render_option
      else
        "#{listing.layout_options[:filters]}_filter"
      end
    end

    def render_option
      @field_description.props.fetch(:render, true)
    end
  end
end
