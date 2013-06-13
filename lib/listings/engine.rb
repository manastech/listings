module Listings
  class Engine < ::Rails::Engine
    isolate_namespace Listings

    ActiveSupport.on_load(:action_view) do
      ::ActionView::Base.send :include, ::Listings::ActionViewExtensions
    end
  end
end
