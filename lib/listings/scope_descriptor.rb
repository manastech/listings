module Listings
  class ScopeDescriptor
    attr_accessor :name

    def initialize(name, props = {})
      props.reverse_merge! default: false

      @name = name
      @props = props
    end

    def human_name
      name.to_s.humanize
    end

    def is_default?
      @props[:default]
    end

    def apply(items)
      if name == :all
        items
      else
        items.send(name)
      end
    end
  end
end