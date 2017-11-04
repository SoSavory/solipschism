class CreateCoordinateArchives < ActiveRecord::Migration[5.0]
  def change
    create_table :coordinate_archives do |t|
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7
      t.integer :alias_id
      t.timestamps
    end
  end
end
