class AdminUser < ApplicationRecord
  include Ransackable
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  enum :user_type, {
    superadmin: 0,
    admin: 1,
    accountant: 2
  }, prefix: true

  validates :user_type, presence: true
end
