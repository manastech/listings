module Listings
  class ColumnView
    def initialize(listing, column_description)
      @listing = listing
      @column_description = column_description
    end

    def value_for(model)
      @column_description.value_for(@listing, model)
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
      @column_description.sortable? && (self.is_model_column? || @column_description.sortable_property_is_expression?)
    end

    def sort_by
      if @column_description.sortable_property_is_expression?
        @column_description.props[:sortable]
      else
        name
      end
    end

    attr_accessor :sort

    def next_sort_direction
      sort == 'asc' ? 'desc' : 'asc'
    end
  end
end
