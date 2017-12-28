class ChangeAliasesToUsers < ActiveRecord::Migration[5.0]
  def change


    remove_foreign_key :matched_aliases, column: :matched_alias_id
    remove_index :matched_aliases, name: "alias_matched_alias_date_index"
    rename_table :matched_aliases, :matched_users
    rename_column :matched_users, :alias_id, :user_id
    rename_column :matched_users, :matched_alias_id, :matched_user_id

    add_foreign_key :matched_users, :users, column: :matched_user_id
    add_index :matched_users, [:user_id, :matched_user_id, :effective_date], unique: true, name: "alias_matched_alias_date_index"

    remove_index :coordinates, name: "index_coordinates_on_alias_id"
    rename_column :coordinates, :alias_id, :user_id
    add_index :coordinates, :user_id, unique: true

    rename_column :articles, :alias_id, :user_id
  end
end
