class CreateSongs < ActiveRecord::Migration[6.0]
  def change
    create_table :songs do |t|
      t.string :name
      t.integer :playlist_id
      t.string :artist_name
    end
  end
end
