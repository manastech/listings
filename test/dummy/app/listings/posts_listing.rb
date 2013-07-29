class PostsListing < Listings::Base  

  model Post

  scope :all, default: true
  scope :even
  scope 'Impares', :odd
  scope 'Mayores a', :greater_than, lambda { params[:gt_id] }

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