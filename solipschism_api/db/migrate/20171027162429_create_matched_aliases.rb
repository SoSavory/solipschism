class CreateMatchedAliases < ActiveRecord::Migration[5.0]
  def change
    create_table :matched_aliases do |t|
      t.integer :alias_id, null: false
      t.integer :matched_alias_id, null: false
      t.date :effective_date, null: false
      t.timestamps

    end

    add_foreign_key :matched_aliases, :aliases, column: :matched_alias_id
    add_index :matched_aliases, [:alias_id, :matched_alias_id, :effective_date], unique: true, name: "alias_matched_alias_date_index"
  end
end
