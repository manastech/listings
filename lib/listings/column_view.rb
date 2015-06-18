module Listings
  class ColumnView
    attr_reader :field

    def initialize(listing, column_description)
      @listing = listing
      @column_description = column_description
      @field = listing.data_source.build_field(column_description.name)
    end

    def value_for(model)
      if @column_description.proc
        # TODO should pass @field.value_for(model) to simplify formatting
        @listing.instance_exec model, &@column_description.proc
      else
        @field.value_for(model)
      end
    end

    def human_name
      @column_description.human_name(@listing)
    end

    def searchable?
      @column_description.searchable?(@listing)
    end

    def is_model_column?
      @column_description.is_model_column?(@listing)
    end

    def name
      @column_description.name
    end

    def sortable?
      @listing.is_sortable? && @column_description.sortable? && (self.is_model_column? || @column_description.sortable_property_is_expression?)
    end

    def sort_by
      if @column_description.sortable_property_is_expression?
        @column_description.props[:sortable]
      else
        name
      end
    end

    def cell_css_class
      @column_description.props[:class]
    end

    attr_accessor :sort

    def next_sort_direction
      sort == 'asc' ? 'desc' : 'asc'
    end
  end
end
