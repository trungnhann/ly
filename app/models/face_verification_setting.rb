# == Schema Information
#
# Table name: face_verification_settings
#
#  id                        :bigint           not null, primary key
#  require_face_verification :boolean          default(TRUE), not null
#  verification_timeout      :integer          default(1800), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  admin_user_id             :bigint           not null, indexed
#
# Indexes
#
#  index_face_verification_settings_on_admin_user_id  (admin_user_id)
#
# Foreign Keys
#
#  fk_rails_...  (admin_user_id => admin_users.id)
#
class FaceVerificationSetting < ApplicationRecord
  belongs_to :admin_user

  validates :verification_timeout, presence: true, numericality: { greater_than: 0 }
  validates :require_face_verification, inclusion: { in: [true, false] }

  def self.default_settings
    {
      verification_timeout: 30.minutes,
      require_face_verification: false
    }
  end
end
