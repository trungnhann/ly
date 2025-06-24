class ChangeDefaultValueForRequireFaceVerification < ActiveRecord::Migration[8.0]
  def up
    change_column_default :face_verification_settings, :require_face_verification, from: true, to: false
  end

  def down
    change_column_default :face_verification_settings, :require_face_verification, from: false, to: true
  end
end
