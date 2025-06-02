class CertificateMetadata
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  # include Auditable
  # include HasStorage

  field :certificate_id, type: String
  field :certificate_type, type: String

  field :issuer, type: String
  field :description, type: String

  field :degree_info, type: Hash, default: {
    level: nil,
    major: nil,
    specialization: nil,
    grade: nil,
    graduation_year: nil
  }

  field :certificate_info, type: Hash, default: {
    provider: nil,
    field: nil,
    score: nil,
    level: nil
  }

  field :certification_info, type: Hash, default: {
    event: nil,
    achievement: nil,     # Thành tích đạt được
    duration: nil,        # Thời lượng
    organizer: nil        # Đơn vị tổ chức
  }

  slug :certificate_id

  validates :certificate_id, presence: true

  before_save :ensure_hash_fields
  before_save :validate_metadata_fields

  def validate_metadata_fields
    case certificate_type
    when 'degree'
      if certificate_info.present? && certificate_info.values.any?(&:present?)
        errors.add(:certificate_info, 'must be empty for degree type')
      end
      if certification_info.present? && certification_info.values.any?(&:present?)
        errors.add(:certification_info, 'must be empty for degree type')
      end
    when 'certificate'
      if degree_info.present? && degree_info.values.any?(&:present?)
        errors.add(:degree_info, 'must be empty for certificate type')
      end
      if certification_info.present? && certification_info.values.any?(&:present?)
        errors.add(:certification_info, 'must be empty for certificate type')
      end
    when 'certification'
      if degree_info.present? && degree_info.values.any?(&:present?)
        errors.add(:degree_info, 'must be empty for certification type')
      end
      if certificate_info.present? && certificate_info.values.any?(&:present?)
        errors.add(:certificate_info, 'must be empty for certification type')
      end
    end
    throw(:abort) if errors.present?
  end

  private

  def ensure_hash_fields
    self.degree_info ||= {}
    self.certificate_info ||= {}
    self.certification_info ||= {}
  end
end
