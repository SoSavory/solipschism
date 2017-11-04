class CreateAliasArchives < ActiveRecord::Migration[5.0]
  def change
    create_table :alias_archives do |t|
      t.integer :user_id, null: false
      t.date :effective_date, null: false
      t.timestamps
    end
  end
end
