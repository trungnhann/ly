class PublicCertificateSerializer < BaseSerializer
  attributes :code, :title, :certificate_type, :issue_date, :expiry_date,
             :is_verified, :created_at, :updated_at

  attribute :metadata do |object|
    object.metadata&.as_json(only: %i[
                               issuer description certificate_type
                               degree_info certificate_info certification_info
                             ])
  end

  attribute :file_url do |object|
    Rails.application.routes.url_helpers.rails_blob_url(object.file, only_path: false) if object.file.attached?
  end

  # Thêm thông tin student trực tiếp vào serializer thay vì dùng relationship
  attribute :student do |object|
    {
      code: object.student.code,
      full_name: object.student.full_name,
      id_card_number: object.student.id_card_number,
      email: object.student.email,
      address: object.student.address,
      phone: object.student.phone,
      major: object.student.major,
      specialization: object.student.specialization,
      avatar_url: object.student.avatar.attached? ? 
        Rails.application.routes.url_helpers.rails_blob_url(object.student.avatar, only_path: false) : nil
    }
  end
end