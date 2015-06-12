class TracksListing < Listings::Base

  model Track

  column :order
  column :title
  # column [:album, :name] # handle has_many relations

end
