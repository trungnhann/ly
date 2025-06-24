# == Schema Information
#
# Table name: face_verification_settings
#
#  id                        :bigint           not null, primary key
#  failed_attempts           :integer          default(0)
#  last_attempt_at           :datetime
#  require_face_verification :boolean          default(FALSE), not null
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
  validates :failed_attempts, numericality: { greater_than_or_equal_to: 0 }

  MAX_FAILED_ATTEMPTS = 3

  def self.default_settings
    {
      verification_timeout: AppSetting.get('VERIFICATION_TIMEOUT', '30').to_i.minutes,
      require_face_verification: false,
      failed_attempts: 0
    }
  end

  def increment_failed_attempts!
    update!(
      failed_attempts: failed_attempts + 1,
      last_attempt_at: Time.current
    )
  end

  def reset_attempts!
    update!(
      failed_attempts: 0,
      last_attempt_at: nil
    )
  end

  def requires_id_card_verification?
    failed_attempts >= MAX_FAILED_ATTEMPTS
  end

  def enable_face_verification!
    update!(
      require_face_verification: true,
      failed_attempts: 0,
      last_attempt_at: nil
    )
  end

  def disable_face_verification!
    update!(require_face_verification: false)
  end
end
