class RemoveRequireFaceVerificationOnNewDevice < ActiveRecord::Migration[8.0]
  def change
    remove_column :face_verification_settings, :require_face_verification_on_new_device, :boolean
  end
end
