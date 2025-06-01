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
class StudentSerializer < BaseSerializer
  attributes :id, :code, :full_name, :id_card_number, :email, :created_at, :updated_at, :metadata, :avatar_url

  attribute :avatar_url do |object|
    Rails.application.routes.url_helpers.rails_blob_url(object.avatar, only_path: false) if object.avatar.attached?
  end

  def metadata
    StudentMetadataSerializer.new(object.metadata).serializable_hash if object.metadata.present?
  end

  has_many :certificates, serializer: CertificateCommonSerializer
end
