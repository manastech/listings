class TracksListing < Listings::Base

  model Track

  # filter album: :name # this also works but will do a distinct over the mode
  filter album: :name, values: :album_names
  filter album: :id, title: 'The Album Id' do |value|
    "#{value}!"
  end
  filter :order, render: false
  filter :label, values: :label_values

  def album_names
    Album.order("name").pluck("distinct name").reject(&:nil?)
  end

  def label_values
    res = ["red", "blue"]
    res << params[:l] if params[:l]
    res
  end

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
