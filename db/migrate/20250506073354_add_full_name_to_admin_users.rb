class AddFullNameToAdminUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :admin_users, :full_name, :string, null: false, default: ''
  end
end
