module Listings
  class ScopeDescriptor
    attr_accessor :human_name
    attr_accessor :name

    def initialize(*args)
      @props = args.extract_options!
      @props.reverse_merge! default: false

      if args.first.is_a? ::Symbol
        @name = args.first
        @human_name = @name.to_s.humanize
      else
        @name = args.second
        @human_name = args.first
      end
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