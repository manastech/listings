class AuthorsListing < Listings::Base
  model do
    Author
  end

  paginates_per 7

  column :name, seachable: true
  column :category
end
