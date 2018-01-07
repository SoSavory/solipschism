class RemoveEffectiveDateFromMatchedUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :matched_users, :effective_date, :date
  end
end
