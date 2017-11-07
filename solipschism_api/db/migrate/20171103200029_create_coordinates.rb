class CreateCoordinates < ActiveRecord::Migration[5.0]
  def change
    create_table :coordinates do |t|
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7
      t.integer :alias_id
      t.timestamps
    end
    add_index :coordinates, :alias_id, unique: true
  end
end
