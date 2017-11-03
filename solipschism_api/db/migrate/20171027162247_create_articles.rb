class CreateArticles < ActiveRecord::Migration[5.0]
  def change
    create_table :articles do |t|
      t.integer :alias_id, null: false
      t.string :title, null: false
      t.text :body, null: false
      
      t.timestamps
    end
  end
end
