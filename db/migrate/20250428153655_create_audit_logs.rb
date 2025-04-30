class CreateAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :audit_logs do |t|
      t.string :record_type, null: false
      t.integer :record_id, null: false
      t.string :action, null: false
      t.jsonb :changes, null: false
      t.references :admin_user, index: true, foreign_key: true
      t.timestamps
    end
    add_index :audit_logs, %i[record_type record_id]
  end
end
