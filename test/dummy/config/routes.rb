Rails.application.routes.draw do

  resources :posts


  root to: 'welcome#index'

  mount Listings::Engine => "/listings"
end
