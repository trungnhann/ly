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
class AdminUser < ApplicationRecord
  include Ransackable
  include Devise::JWT::RevocationStrategies::JTIMatcher
  belongs_to :student, optional: true
  # include Auditable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  enum :user_type, {
    superadmin: 'superadmin',
    admin: 'admin',
    student: 'student'
  }, prefix: true

  validates :user_type, presence: true
end
