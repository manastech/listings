class HashListing < Listings::Base

  model do
    (1..30).map do |n|
      { :self => n, :next => n + 1 }
    end
  end

  paginates_per 10

  column :self
  column :next
  column 'dummy' do
    'This is a string'
  end
  column 'format' do
    format
  end

  export :csv, :xls

end
