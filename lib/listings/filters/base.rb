module Listings
  class Base
    def render_filters_at?(loc)
      self.filterable? && layout_options[:filters] == loc
    end
  end
end
