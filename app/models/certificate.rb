# == Schema Information
#
# Table name: certificates
#
#  id               :bigint           not null, primary key
#  certificate_type :string           not null
#  code             :string           not null, indexed
#  expiry_date      :date
#  is_verified      :boolean          default(TRUE)
#  issue_date       :date             not null
#  title            :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  metadata_id      :string
#  student_id       :bigint           not null, indexed
#
# Indexes
#
#  index_certificates_on_code        (code) UNIQUE
#  index_certificates_on_student_id  (student_id)
#
# Foreign Keys
#
#  fk_rails_...  (student_id => students.id)
#
class Certificate < ApplicationRecord
  include Ransackable
  # include Auditable

  belongs_to :student

  enum :certificate_type, {
    degree: 'degree',
    certificate: 'certificate',
    certification: 'certification'
  }

  CERTIFICATE_TYPES = {
    DEGREE: 'degree',
    CERTIFICATE: 'certificate',
    CERTIFICATION: 'certification'
  }.freeze

  attr_accessor :metadata_issuer, :metadata_description, :metadata_image_path, :metadata_degree_level,
                :metadata_degree_major, :metadata_degree_specialization, :metadata_degree_grade,
                :metadata_degree_graduation_year, :metadata_certificate_provider,
                :metadata_certificate_field, :metadata_certificate_score, :metadata_certificate_level,
                :metadata_certification_event, :metadata_certification_achievement, :metadata_certification_duration,
                :metadata_certification_organizer

  validates :code, presence: true, uniqueness: true
  validates :title, presence: true
  validates :certificate_type, presence: true, inclusion: { in: Certificate.certificate_types.keys }
  validates :issue_date, presence: true

  after_create :ensure_metadata_created
  after_create :process_pending_metadata

  after_update :sync_certificate_type_to_metadata, if: :saved_change_to_certificate_type?

  before_destroy :cleanup_metadata

  scope :filter_by_code, ->(code) { where('code ILIKE ?', code) }
  scope :filter_by_certificate_type, ->(certificate_type) { where(certificate_type: certificate_type) }

  def metadata
    return nil if metadata_id.blank?

    CertificateMetadata.find(metadata_id)
  end

  def metadata=(metadata_attributes)
    return if metadata_attributes.blank?

    if new_record?
      @pending_metadata = metadata_attributes
    elsif metadata_id.present? && metadata
      metadata.update(metadata_attributes)
    else
      meta = CertificateMetadata.create(metadata_attributes.merge(certificate_id: id.to_s,
                                                                  certificate_type: certificate_type))
      update_column(:metadata_id, meta.id.to_s)
    end
  end

  def process_pending_metadata
    return if @pending_metadata.blank?

    meta = CertificateMetadata.create(@pending_metadata.merge(certificate_id: id.to_s,
                                                              certificate_type: certificate_type))
    update_column(:metadata_id, meta.id.to_s)
    @pending_metadata = nil
  end

  private

  def ensure_metadata_created
    return if metadata_id.present?

    metadata = CertificateMetadata.create!(
      certificate_id: id.to_s,
      certificate_type: certificate_type
    )
    update_column(:metadata_id, metadata.id.to_s)
  end

  def cleanup_metadata
    CertificateMetadata.where(certificate_id: id.to_s).destroy_all if metadata_id.present?
  end

  def sync_certificate_type_to_metadata
    return if metadata_id.blank?

    meta = CertificateMetadata.find_by(id: metadata_id)
    return if meta.blank?

    meta.update(certificate_type: certificate_type)
  end
end
