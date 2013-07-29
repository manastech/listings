require 'listings/dynamic_binding'

module Listings
  class ScopeDescriptor
    attr_accessor :human_name
    attr_accessor :name
    attr_accessor :params_lambda

    def initialize(*args)
      @props = args.extract_options!
      @props.reverse_merge! default: false
      @params_lambda = args.last if args.last.is_a? Proc

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

    def apply(context, items)
      if name == :all
        items
      else
        if @params_lambda.nil?
          items.send(name)
        else
          ls = ::DynamicBinding::LookupStack.new
          ls.push_instance context
          args = ls.run_proc @params_lambda
          items.send(name, args)
        end
      end
    end
  end
end