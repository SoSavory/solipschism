class CreateMatchedAliases < ActiveRecord::Migration[5.0]
  def change
    create_table :matched_aliases do |t|
      t.integer :alias_1_id, null: false
      t.integer :alias_2_id, null: false
      t.date :effective_date, null: false
      t.timestamps
    end
  end
end
