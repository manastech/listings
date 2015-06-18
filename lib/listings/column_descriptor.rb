module Listings
  class ColumnDescriptor < BaseFieldDescriptor
    def initialize(path, props, proc)
      props = props.reverse_merge! searchable: false, sortable: true
      super(path, props, proc)
    end

    def searchable?
      @props[:searchable] && is_field?
    end

    def sortable?
      @props[:sortable] && is_field?
    end
  end
end
