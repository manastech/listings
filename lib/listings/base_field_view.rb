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

      fallback = if is_model_column?
        listing.model_class.human_attribute_name(path)
      else
        p = ::Listings::Sources::DataSource.sanitaize_path(path)
        p = [p] unless p.is_a?(Array)
        p.join(' ')
      end

      I18n.t("listings.headers.#{listing.name}.#{key}", default: fallback)
    end

    def key
      if @field
        @field.key
      else
        path
      end
    end

    def is_model_column?
      path.is_a?(Symbol) && listing.has_active_model_source?
    end
  end
end
