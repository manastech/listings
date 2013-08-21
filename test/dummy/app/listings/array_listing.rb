class ArrayListing < Listings::Base

  model { (1..30).to_a }

  paginates_per 10

  column 'Num' do |n|
    n
  end

  column 'Num+1' do |n|
    n+1
  end

end
