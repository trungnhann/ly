class IdCardVerificationService
  def self.call(id_card_image)
    new(id_card_image).call
  end

  def call
    @current_user = Current.user
    @setting = FaceVerificationSetting.find_by(admin_user: Current.user)
    verify_id_card
  end

  private

  attr_reader :current_user, :setting

  def initialize(id_card_image)
    @id_card_image = id_card_image
  end

  def verify_id_card
    return false unless current_user&.user_type == 'student'

    id_card_data = FptAi::IdCardVerifyService.call(image_file: @id_card_image)
    student = current_user.student
    success = validate_id_card_data(id_card_data, student)

    if success
      setting.reset_attempts!
      true
    else
      Rails.logger.error('Xác thực CCCD thất bại: Thông tin CCCD không khớp với thông tin sinh viên')
      false
    end
  end

  def validate_id_card_data(id_card_data, student)
    return false if id_card_data.blank?

    normalize_name(id_card_data[:full_name]) == normalize_name(student.full_name) &&
      id_card_data[:number] == student.id_card_number
  end

  def normalize_name(name)
    return '' if name.blank?

    name.to_s.downcase.strip.gsub(/\s+/, ' ')
  end
end
