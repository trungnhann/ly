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
