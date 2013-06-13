class ListingsController < ActionController::Base
  include ListingsHelper

  def index
    listing = prepare_listing params, view_context
    render :partial => 'listings/index', :locals => { :listing => listing }
  end

end