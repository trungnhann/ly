class RenameChangesToAuditedChangesInAuditLogs < ActiveRecord::Migration[8.0]
  def change
    rename_column :audit_logs, :changes, :audited_changes
  end
end
