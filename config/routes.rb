Listings::Engine.routes.draw do
  get 'listing/:listing/full' => 'listings#full', as: :listing_full
  get 'listing/:listing/content' => 'listings#content', as: :listing_content
  get 'listing/:listing/export' => 'listings#export', as: :listing_export
end
