# == Schema Information
#
# Table name: audit_logs
#
#  id              :bigint           not null, primary key
#  action          :string           not null
#  audited_changes :jsonb            not null
#  record_type     :string           not null, indexed => [record_id]
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  admin_user_id   :bigint           indexed
#  record_id       :integer          not null, indexed => [record_type]
#
# Indexes
#
#  index_audit_logs_on_admin_user_id              (admin_user_id)
#  index_audit_logs_on_record_type_and_record_id  (record_type,record_id)
#
# Foreign Keys
#
#  fk_rails_...  (admin_user_id => admin_users.id)
#
class AuditLog < ApplicationRecord
  validates :record_type, :record_id, :action, :audited_changes, presence: true

  def as_json(options = {})
    super({
      only: %i[id record_type record_id action audited_changes created_at],
      methods: %i[admin_user]
    }.merge(options))
  end

  def admin_user
    return nil unless admin_user_id

    user = AdminUser.find_by(id: admin_user_id)
    return nil unless user

    {
      id: user.id,
      email: user.email,
      user_type: user.user_type
    }
  end
end
