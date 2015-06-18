module Listings
  class ColumnDescriptor < BaseFieldDescriptor
    attr_reader :proc

    def initialize(path, props, proc)
      props = props.reverse_merge! searchable: false, sortable: true
      super(path, props)
      @proc = proc
    end

    def searchable?
      @props[:searchable]
    end

    def sortable?
      s = @props[:sortable]
      if sortable_property_is_expression?
        true # s is the expression that should be used for sorting
      else
        s # s is Boolean
      end
    end

    def sortable_property_is_expression?
      s = @props[:sortable]
      !(!!s == s)
    end
  end
end
