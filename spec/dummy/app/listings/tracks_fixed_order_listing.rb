class TracksFixedOrderListing < Listings::Base

  model Track

  sortable false

  filter album: :name

  column :order
  column :title
  column album: :name

end
