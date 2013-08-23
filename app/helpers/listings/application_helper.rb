module Listings
  module ApplicationHelper
    def excel_type(value)
      if value.is_a?(Fixnum) || value.is_a?(Float)
        "Number"
      else
        "String"
      end
    end
  end
end
