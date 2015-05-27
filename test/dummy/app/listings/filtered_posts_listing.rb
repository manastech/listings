class FilteredPostsListing < Listings::Base

  model Post

  paginates_per 10

  scope :all, default: true
  scope :even
  scope :odd

  filter :author
  filter :category


  column :id
  column :title, searchable: true
  column :author
  column :category
  column do |post|
    link_to 'Editar', edit_post_path(post)
  end

end
