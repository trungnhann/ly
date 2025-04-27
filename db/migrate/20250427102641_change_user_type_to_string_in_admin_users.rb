class ChangeUserTypeToStringInAdminUsers < ActiveRecord::Migration[8.0]
  def change
    change_column :admin_users, :user_type, :string
  end
end
