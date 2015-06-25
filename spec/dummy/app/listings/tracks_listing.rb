class TracksListing < Listings::Base

  model Track

  filter album: :name
  filter album: :id, title: 'The Album Id' do |value|
    "#{value}!"
  end
  filter :order, render: false

  custom_filter :order_lte do |items, value|
    items.where('"order" <= ?', value.to_i)
  end

  column :order
  column :title, searchable: true
  column album: :name, searchable: true do |track, album_name|
    "#{album_name} (Buy!)"
  end

  column album: :id, title: 'The Album Id'

end
