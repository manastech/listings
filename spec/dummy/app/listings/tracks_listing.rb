class TracksListing < Listings::Base

  model Track

  filter album: :name
  filter album: :id, title: 'The Album Id'

  column :order
  column :title, searchable: true
  column album: :name, searchable: true
  column album: :id, title: 'The Album Id'

end
