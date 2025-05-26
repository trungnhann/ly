class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.string :notification_type, null: false
      t.boolean :is_read, default: false
      t.references :admin_user, null: false, foreign_key: true
      t.timestamps
    end

    add_index :notifications, :notification_type
    add_index :notifications, :is_read
  end
end
