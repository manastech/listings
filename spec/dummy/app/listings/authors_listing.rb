class AuthorsListing < Listings::Base
  model do
    Author
      .select('authors.*, (select count(*) from posts where posts.author_id = authors.id) as posts_count')
  end

  paginates_per 7

  filter :category, values: :categories

  custom_filter :posts_count_eq, render: 'posts_count' do |items, value|
    items.where("(select count(*) from posts where posts.author_id = authors.id) = ?", value.to_i)
  end

  def categories
    Author.select('distinct category').pluck(:category).reject(&:nil?)
  end

  def query_counts
    (1..30).to_a
  end

  column :name, seachable: true
  column :posts_count, query_column: :posts_count
  column :category
end
