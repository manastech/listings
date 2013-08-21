Rails.application.routes.draw do

  resources :posts

  get 'array', to: 'welcome#array'
  get 'hash', to: 'welcome#hash'
  root to: 'welcome#index'

  mount Listings::Engine => "/listings"
end
