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
#  editor_name     :string
#  editor_email    :string
#  record_id       :integer          not null, indexed => [record_type]
#
# Indexes
#
#  index_audit_logs_on_record_type_and_record_id  (record_type,record_id)
#
class AuditLog < ApplicationRecord
  validates :record_type, :record_id, :action, :audited_changes, presence: true

  def as_json(options = {})
    super({
      only: %i[id record_type record_id action audited_changes created_at editor_name editor_email]
    }.merge(options))
  end
end
