module Listings
  class CustomFilterView
    attr_reader :listing
    attr_reader :descriptor

    def initialize(listing, descriptor)
      @listing = listing
      @descriptor = descriptor
    end

    def prepare_values
      # custom filters do not perform lookup
    end

    def key
      @descriptor.key
    end

    def apply_filter(value)
      listing.data_source.transform_items do |items|
        listing.instance_exec items, value, &@descriptor.proc
      end
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
        raise "custom filters can only be rendered when a partial is specified"
      end
    end

    def render_option
      @descriptor.props.fetch(:render, false)
    end
  end
end
