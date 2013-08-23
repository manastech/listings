module Listings
  module ApplicationHelper
    def excel_type(value)
      if value.is_a?(Fixnum) || value.is_a?(Float)
        "Number"
      elsif !!value == value
        "Boolean"
      else
        "String"
      end
    end

    def excel_value(value)
      if !!value == value
        value ? 1 : 0
      else
        value
      end
    end
  end
end
