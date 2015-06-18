module Listings
  class ColumnView < BaseFieldView
    def initialize(listing, column_description)
      super
    end

    def column_description
      @field_description
    end

    def value_for(model)
      if @field_description.proc
        if is_field?
          listing.instance_exec model, field.value_for(model), &@field_description.proc
        else
          listing.instance_exec model, &@field_description.proc
        end
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
