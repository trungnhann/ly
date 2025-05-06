# == Schema Information
#
# Table name: students
#
#  id             :bigint           not null, primary key
#  code           :string           not null, indexed
#  email          :string           not null, indexed
#  full_name      :string           not null
#  id_card_number :string           not null, indexed
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
  has_one :admin_user

  METADATA_FIELDS = {
    metadata_phone: :phone,
    metadata_major: :major,
    metadata_specialization: :specialization
  }.freeze

  has_one_attached :avatar

  has_many :certificates, dependent: :destroy

  attr_accessor :metadata_phone, :metadata_major, :metadata_specialization

  validates :code, presence: true, uniqueness: true
  validates :full_name, presence: true
  validates :id_card_number, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_destroy :cleanup_metadata

  scope :filter_by_code, ->(code) { where('code ILIKE ?', code) }
  scope :filter_by_full_name, ->(name) { where('full_name ILIKE ?', "%#{name}%") }
  scope :filter_by_id_card_number, ->(number) { where('id_card_number ILIKE ?', number) }
  scope :filter_by_email, ->(email) { where('email ILIKE ?', "%#{email}%") }
  scope :filter_by_created_at, lambda { |date_range|
    start_date, end_date = date_range.split(',').map(&:strip)
    where(created_at: start_date.to_date.beginning_of_day..end_date.to_date.end_of_day)
  }

  def metadata
    @metadata ||= StudentMetadata.where(student_id: id.to_s).first
  end

  def create_or_update_metadata(params)
    meta_params = {
      phone: params['metadata_phone'],
      major: params['metadata_major'],
      specialization: params['metadata_specialization']
    }.compact

    existing_metadata = metadata
    if existing_metadata
      existing_metadata.update!(meta_params)
    else
      StudentMetadata.create!(meta_params.merge(student_id: id.to_s))
    end
  end

  private

  METADATA_FIELDS.each do |method_name, field_name|
    define_method(method_name) do
      metadata&.send(field_name)
    end
  end

  def cleanup_metadata
    if metadata.present?
      Rails.logger.info "Deleting metadata for student #{id} - metadata ID: #{metadata.id}"
      metadata.delete
    else
      Rails.logger.warn "No metadata found for student #{id} to delete"
    end
  rescue StandardError => e
    Rails.logger.error "Failed to delete metadata for student #{id}: #{e.message}"
    raise e
  end
end
