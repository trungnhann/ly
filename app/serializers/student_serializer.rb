class StudentSerializer < BaseSerializer
  attributes :id, :code, :full_name, :id_card_number, :email, :created_at, :updated_at, :metadata

  def metadata
    StudentMetadataSerializer.new(object.metadata).serializable_hash if object.metadata.present?
  end
end
