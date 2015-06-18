class TracksListing < Listings::Base

  model Track

  filter album: :name

  column :order
  column :title
  column album: :name

end
