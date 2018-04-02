class ApplicationController < ActionController::Base
  protect_from_forgery

  if Rails::VERSION::MAJOR < 5
    before_filter do
      Listings.configuration.theme = params[:theme] || Listings::Configuration.new.theme
    end
  else
    before_action do
      Listings.configuration.theme = params[:theme] || Listings::Configuration.new.theme
    end
  end
end
