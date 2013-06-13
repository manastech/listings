Rails.application.routes.draw do

  mount Listings::Engine => "/listings"
end
