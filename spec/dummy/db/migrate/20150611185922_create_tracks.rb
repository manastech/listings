class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.string :title
      t.integer :order
      t.references :album

      t.timestamps
    end
    add_index :tracks, :album_id
  end
end
