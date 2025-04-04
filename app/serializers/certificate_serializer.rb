class CertificateSerializer < BaseSerializer
  attributes :id, :code, :title, :certificate_type, :issue_date, :expiry_date, :is_verified, :student_id,
             :metadata_id, :created_at, :updated_at
end
