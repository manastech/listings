class PostsListing < Listings::Base  

  model Post

  scope :all, default: true
  scope :even
  scope 'Impares', :odd

  paginates_per 10

  column :id
  column :title, searchable: true
  column :author, searchable: true
  column do |post|
    link_to 'Editar', edit_post_path(post)
  end
  column do |post|
    h "<b>#{post.title}</b>"
  end

end