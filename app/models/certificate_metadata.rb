class CertificateMetadata
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  # include HasStorage

  field :certificate_id, type: String
  field :certificate_type, type: Integer

  # Các trường chung cho tất cả loại chứng chỉ
  field :issuer, type: String
  field :description, type: String
  field :image_path, type: String

  # Trường metadata cho từng loại chứng chỉ
  # Type 1: Bằng Cấp
  field :degree_info, type: Hash, default: {
    level: nil,           # Cấp bậc (Đại học, Thạc sĩ, Tiến sĩ)
    major: nil,           # Ngành học
    specialization: nil,  # Chuyên ngành
    grade: nil, # Xếp loại
    graduation_year: nil # Năm tốt nghiệp
  }

  # Type 2: Chứng Chỉ
  field :certificate_info, type: Hash, default: {
    provider: nil,       # Đơn vị cấp chứng chỉ
    field: nil,          # Lĩnh vực
    score: nil,          # Điểm số/Kết quả
    level: nil           # Cấp độ/Trình độ
  }

  # Type 3: Chứng Nhận
  field :certification_info, type: Hash, default: {
    event: nil, # Sự kiện/Khóa học
    achievement: nil,     # Thành tích đạt được
    duration: nil,        # Thời lượng
    organizer: nil        # Đơn vị tổ chức
  }

  slug :certificate_id

  validates :certificate_id, presence: true
  # validates :certificate_type, presence: true, inclusion: { in: 1..3 }

  before_save :ensure_hash_fields
  before_save :validate_metadata_fields

  def validate_metadata_fields
    case certificate_type
    when 1 # Bằng Cấp
      if certificate_info.present? && certificate_info.values.any?(&:present?)
        errors.add(:certificate_info,
                   'must be empty for degree type')
      end
      if certification_info.present? && certification_info.values.any?(&:present?)
        errors.add(:certification_info,
                   'must be empty for degree type')
      end
    when 2 # Chứng Chỉ
      if degree_info.present? && degree_info.values.any?(&:present?)
        errors.add(:degree_info,
                   'must be empty for certificate type')
      end
      if certification_info.present? && certification_info.values.any?(&:present?)
        errors.add(:certification_info,
                   'must be empty for certificate type')
      end
    when 3 # Chứng Nhận
      if degree_info.present? && degree_info.values.any?(&:present?)
        errors.add(:degree_info,
                   'must be empty for certification type')
      end
      if certificate_info.present? && certificate_info.values.any?(&:present?)
        errors.add(:certificate_info,
                   'must be empty for certification type')
      end
    end
    throw(:abort) if errors.present?
  end

  #   def image=(file)
  #     return if file.blank?

  #     self.image_path = upload_file(file, "certificates/#{certificate_id}/#{Time.current.to_i}")
  #   end

  private

  def ensure_hash_fields
    self.degree_info ||= {}
    self.certificate_info ||= {}
    self.certification_info ||= {}
  end
end
