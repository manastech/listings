class FilteredPostsListing < Listings::Base

  model Post

  paginates_per 10

  # layout filters: :top

  scope :all, default: true
  scope :even
  scope :odd

  filter :author
  filter :category

  custom_filter :updated, render: 'date' do |items, value|
    begin
      d = Date.parse(value)
      items.where(updated_at: d.beginning_of_day..d.end_of_day)
    rescue
      items
    end
  end


  column :id
  column :title, searchable: true
  column :author
  column :category
  column :updated_at

  column do |post|
    link_to 'Editar', edit_post_path(post)
  end

end
