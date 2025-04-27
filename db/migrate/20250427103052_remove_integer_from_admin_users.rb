class RemoveIntegerFromAdminUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :admin_users, :integer
  end
end
