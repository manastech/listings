Rails.application.routes.draw do

  resources :posts do
    collection do
      get 'filtered'
    end
  end

  get 'array', to: 'welcome#array'
  get 'hash', to: 'welcome#hash'
  get 'tracks', to: 'welcome#tracks'

  root to: 'welcome#index'

  mount Listings::Engine => "/listings"
end
