class TracksListing < Listings::Base

  model Track

  column :order
  column :title
  column album: :name

end
