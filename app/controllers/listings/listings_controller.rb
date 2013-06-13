module Listings
  class ListingsController < ActionController::Base
    include ActionViewExtensions

    def index
      listing = prepare_listing params, view_context
      render :partial => 'listings/index', :locals => { :listing => listing }
    end

  end
end