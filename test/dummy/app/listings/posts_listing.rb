class PostsListing < Listings::Base

  model Post

  scope :all, default: true
  scope :even
  scope 'Impares', :odd
  scope 'Mayores a', :greater_than, lambda { |items| items.greater_than(params[:gt_id]) }

  paginates_per 10

  row_style do |post|
    'my-class' if post.id % 2 == 0
  end

  column :id
  column :title, searchable: true
  column :author, searchable: true
  column do |post|
    link_to 'Editar', edit_post_path(post)
  end
  column do |post|
    h "<b>#{post.title}</b>"
  end
  column do |post|
    render partial: 'shared/post_partial', locals: {post: post}
  end

  export :csv

  # selectable do |post|
  #   post.id
  # end

  # selectable :id

  selectable

end
