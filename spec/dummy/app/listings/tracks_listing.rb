class TracksListing < Listings::Base

  model Track

  filter album: :name
  filter album: :id, title: 'The Album Id' do |value|
    "#{value}!"
  end

  column :order
  column :title, searchable: true
  column album: :name, searchable: true do |track, album_name|
    "#{album_name} (Buy!)"
  end

  column album: :id, title: 'The Album Id'

end
