class PostsListing < Listings::Base  

  model Post

  scope :all, default: true
  scope :even
  scope :odd

  paginates_per 10

  column :id
  column :title
  column do |post|
    link_to 'Editar', edit_post_path(post)
  end

end