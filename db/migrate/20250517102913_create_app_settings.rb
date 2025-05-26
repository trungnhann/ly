class CreateAppSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :app_settings do |t|
      t.string :key_name, null: false
      t.string :key_value, null: false
      t.jsonb :metadata, default: {}
      t.string :description
      t.timestamps
    end
    add_index :app_settings, :key_name, unique: true
  end
end
