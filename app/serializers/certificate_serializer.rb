# == Schema Information
#
# Table name: certificates
#
#  id               :bigint           not null, primary key
#  certificate_type :string           not null
#  code             :string           not null, indexed
#  expiry_date      :date
#  is_public        :boolean          default(FALSE)
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
class CertificateSerializer < BaseSerializer
  attributes :code, :title, :certificate_type, :issue_date, :expiry_date,
             :is_verified, :student_id, :metadata_id, :is_public, :created_at, :updated_at

  attribute :metadata do |object|
    object.metadata&.as_json(only: %i[
                               issuer description certificate_type
                               degree_info certificate_info certification_info
                             ])
  end

  attribute :file_url do |object|
    Rails.application.routes.url_helpers.rails_blob_url(object.file, only_path: false) if object.file.attached?
  end

  belongs_to :student, serializer: StudentSerializer
end
