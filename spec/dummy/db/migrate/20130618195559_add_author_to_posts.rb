class AddAuthorToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :author, :text
  end
end
