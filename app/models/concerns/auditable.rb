# app/models/concerns/auditable.rb
module Auditable
  extend ActiveSupport::Concern

  included do
    after_create :audit_create
    after_update :audit_update
    after_destroy :audit_destroy
  end

  private

  def audit_create
    create_audit_log('create', changes_for_audit)
  end

  def audit_update
    create_audit_log('update', changes_for_audit)
  end

  def audit_destroy
    create_audit_log('destroy', attributes_for_audit)
  end

  def create_audit_log(action, changes)
    return if changes.blank?

    AuditLog.create!(
      record_type: self.class.name,
      record_id: id,
      action:,
      audited_changes: changes,
      editor_name: Current.user&.full_name,
      editor_email: Current.user&.email
    )
  end

  def changes_for_audit
    previous_changes.transform_values do |values|
      {
        'from' => values.first,
        'to' => values.last
      }
    end
  end

  def attributes_for_audit
    attributes.transform_values do |value|
      {
        'from' => value,
        'to' => nil
      }
    end
  end
end
