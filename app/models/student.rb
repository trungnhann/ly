class Student < ApplicationRecord
  has_one :metadata, class_name: 'StudentMetadata', dependent: :destroy

  validates :code, presence: true, uniqueness: true
  validates :full_name, presence: true
  validates :id_card_number, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :filter_by_code, ->(code) { where('code ILIKE ?', "%#{code}%") }
  scope :filter_by_full_name, ->(name) { where('full_name ILIKE ?', "%#{name}%") }
  scope :filter_by_id_card_number, ->(number) { where('id_card_number ILIKE ?', "%#{number}%") }
  scope :filter_by_email, ->(email) { where('email ILIKE ?', "%#{email}%") }
  scope :filter_by_created_at, ->(date_range) {
    start_date, end_date = date_range.split(',').map(&:strip)
    where(created_at: start_date.to_date.beginning_of_day..end_date.to_date.end_of_day)
  }

  def metadata
    StudentMetadata.find_by(student_id: id)
  rescue StandardError
    nil
  end

  def metadata=(metadata_attributes)
    if metadata
      metadata.update(metadata_attributes)
    else
      StudentMetadata.create(metadata_attributes.merge(student_id: id))
    end
  end
end
