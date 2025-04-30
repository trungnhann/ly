# == Schema Information
#
# Table name: certificates
#
#  id               :bigint           not null, primary key
#  certificate_type :string           not null
#  code             :string           not null, indexed
#  expiry_date      :date
#  is_verified      :boolean          default(TRUE)
#  issue_date       :date             not null
#  title            :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  metadata_id      :string
#  student_id       :bigint           not null, indexed
#
# Indexes
#
#  index_certificates_on_code        (code) UNIQUE
#  index_certificates_on_student_id  (student_id)
#
# Foreign Keys
#
#  fk_rails_...  (student_id => students.id)
#
require 'test_helper'

class CertificateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
