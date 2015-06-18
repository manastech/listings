module Listings
  class BaseFieldView
    attr_reader :field
    attr_reader :listing

    def initialize(listing, field_description)
      @listing = listing
      @field_description = field_description
      @field = if @field_description.is_field?
        @field_description.build_field(listing)
      else
        nil
      end
    end

    def path
      @field_description.path
    end

    def human_name
      return path if path.is_a?(String)

      I18n.t("listings.headers.#{listing.name}.#{key}", default: listing.human_name(field))
    end

    def key
      if @field
        @field.key
      else
        path
      end
    end

    def is_field?
      @field_description.is_field?
    end
  end
end
