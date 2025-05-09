# == Schema Information
#
# Table name: admin_users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null, indexed
#  encrypted_password     :string           default(""), not null
#  full_name              :string           default(""), not null
#  jti                    :string           indexed
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string           indexed
#  user_type              :string           default(NULL), indexed
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  student_id             :bigint           indexed
#
# Indexes
#
#  index_admin_users_on_email                 (email) UNIQUE
#  index_admin_users_on_jti                   (jti)
#  index_admin_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_admin_users_on_student_id            (student_id)
#  index_admin_users_on_user_type             (user_type)
#
# Foreign Keys
#
#  fk_rails_...  (student_id => students.id)
#
class AdminUserSerializer < BaseSerializer
  attributes :id, :email, :user_type, :created_at, :student_id, :updated_at, :face_verification_setting
  def face_verification_setting
    return nil unless object.face_verification_setting

    {
      require_face_verification: object.face_verification_setting.require_face_verification
    }
  end
end
