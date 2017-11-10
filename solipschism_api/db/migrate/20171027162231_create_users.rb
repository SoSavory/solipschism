class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :token, index: true
      t.string :password_digest, null: false

      t.boolean :opts_to_compute, default: false, index: true
      t.timestamps
    end
  end
end
