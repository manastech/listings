class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter do
    Listings.configuration.theme = params[:theme] || Listings::Configuration.new.theme
  end
end
