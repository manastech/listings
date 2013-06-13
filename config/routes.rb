Listings::Engine.routes.draw do
  match 'listing/:listing' => 'listings#index'
end
