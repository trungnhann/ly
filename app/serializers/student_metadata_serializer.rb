class StudentMetadataSerializer < BaseSerializer
  attributes :id, :student_id, :id_card, :phone, :major, :specialization, :created_at, :updated_at,
             :avatar_url, :id_card_front_url, :id_card_back_url

  def id
    object._id.to_s
  end
end
