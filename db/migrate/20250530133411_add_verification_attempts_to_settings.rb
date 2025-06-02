class AddVerificationAttemptsToSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :face_verification_settings, :failed_attempts, :integer, default: 0
    add_column :face_verification_settings, :last_attempt_at, :datetime
  end
end
