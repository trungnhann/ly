# == Schema Information
#
# Table name: students
#
#  id             :bigint           not null, primary key
#  address        :string
#  code           :string           not null, indexed
#  email          :string           not null, indexed
#  full_name      :string           not null
#  id_card_number :string           not null, indexed
#  major          :string
#  phone          :string
#  specialization :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_students_on_code            (code) UNIQUE
#  index_students_on_email           (email) UNIQUE
#  index_students_on_id_card_number  (id_card_number) UNIQUE
#
class Student < ApplicationRecord
  include Ransackable
  include Auditable
  has_one :admin_user, dependent: :destroy

  has_one_attached :avatar

  has_many :certificates, dependent: :destroy

  validates :code, presence: true, uniqueness: true
  validates :full_name, presence: true
  validates :id_card_number, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :filter_by_code, ->(code) { where('code ILIKE ?', code) }
  scope :filter_by_full_name, ->(name) { where('full_name ILIKE ?', "%#{name}%") }
  scope :filter_by_id_card_number, ->(number) { where('id_card_number ILIKE ?', number) }
  scope :filter_by_email, ->(email) { where('email ILIKE ?', "%#{email}%") }
  scope :filter_by_created_at, lambda { |date_range|
    start_date, end_date = date_range.split(',').map(&:strip)
    where(created_at: start_date.to_date.beginning_of_day..end_date.to_date.end_of_day)
  }
end
