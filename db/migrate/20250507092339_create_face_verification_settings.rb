class CreateFaceVerificationSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :face_verification_settings do |t|
      t.references :admin_user, null: false, foreign_key: true
      t.integer :verification_timeout, null: false, default: 1800
      t.boolean :require_face_verification, null: false, default: true
      t.boolean :require_face_verification_on_new_device, null: false, default: true

      t.timestamps
    end
  end
end
