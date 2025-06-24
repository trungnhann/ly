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
require 'test_helper'

class AuditLogTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
