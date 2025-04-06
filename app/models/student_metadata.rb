class StudentMetadata
  include Mongoid::Document
  include Mongoid::Timestamps
  include HasStorage

  field :student_id, type: String
  field :phone, type: String
  field :major, type: String
  field :specialization, type: String
  field :avatar_path, type: String
  field :id_card_front_path, type: String
  field :id_card_back_path, type: String

  index({ student_id: 1 }, { unique: true })

  validates :student_id, presence: true, uniqueness: true

  def avatar_url
    file_url(avatar_path) if avatar_path.present?
  end

  def id_card_front_url
    file_url(id_card_front_path) if id_card_front_path.present?
  end

  def id_card_back_url
    file_url(id_card_back_path) if id_card_back_path.present?
  end

  def avatar=(file)
    return if file.blank?

    self.avatar_path = upload_file(file, "avatars/#{student_id}/#{Time.current.to_i}")
  end

  def id_card_front=(file)
    return if file.blank?

    self.id_card_front_path = upload_file(file, "id_cards/#{student_id}/front/#{Time.current.to_i}")
  end

  def id_card_back=(file)
    return if file.blank?

    self.id_card_back_path = upload_file(file, "id_cards/#{student_id}/back/#{Time.current.to_i}")
  end
end
