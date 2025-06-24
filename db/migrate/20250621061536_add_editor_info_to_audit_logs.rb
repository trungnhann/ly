class AddEditorInfoToAuditLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :audit_logs, :editor_name, :string
    add_column :audit_logs, :editor_email, :string
    remove_reference :audit_logs, :admin_user, foreign_key: true
  end
end