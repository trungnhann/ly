# == Schema Information
#
# Table name: audit_logs
#
#  id              :bigint           not null, primary key
#  action          :string           not null
#  audited_changes :jsonb            not null
#  editor_email    :string
#  editor_name     :string
#  record_type     :string           not null, indexed => [record_id]
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  record_id       :integer          not null, indexed => [record_type]
#
# Indexes
#
#  index_audit_logs_on_record_type_and_record_id  (record_type,record_id)
#
class AuditLogSerializer < BaseSerializer
  attributes :id, :created_at, :updated_at,
             :action, :audited_changes,
             :record_type, :record_id,
             :admin_user

  def admin_user
    return nil unless object.admin_user_id

    user = AdminUser.find_by(id: object.admin_user_id)
    return nil unless user

    {
      id: user.id,
      email: user.email,
      user_type: user.user_type
    }
  end
end
