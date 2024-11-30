class CreateUrls < ActiveRecord::Migration[7.1]
  def change
    create_table :urls do |t|
      t.string :original_url, null: false
      t.string :short_url, null: false

      t.timestamps
    end
    add_index :urls, :original_url, unique: true
    add_index :urls, :short_url, unique: true
  end
end
