module Listings
  class ColumnView < BaseFieldView
    def initialize(listing, column_description)
      super
    end

    def column_description
      @field_description
    end

    # TODO move to base_field_view
    def value_for(model)
      if column_description.proc
        # TODO should pass @field.value_for(model) to simplify formatting
        listing.instance_exec model, &column_description.proc
      else
        field.value_for(model)
      end
    end

    def searchable?
      column_description.searchable?
    end

    def sortable?
      listing.sortable? && column_description.sortable?
    end

    def cell_css_class
      column_description.props[:class]
    end

    attr_accessor :sort

    def next_sort_direction
      self.sort == Sources::DataSource::ASC ? Sources::DataSource::DESC : Sources::DataSource::ASC
    end
  end
end
