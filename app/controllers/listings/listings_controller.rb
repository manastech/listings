module Listings
  class ListingsController < ActionController::Base
    include ActionViewExtensions

    def full
      @listing = prepare_listing params, view_context
      render 'listings/full'
    end

    def content
      @listing = prepare_listing params, view_context
      render 'listings/content'
    end

  end
end