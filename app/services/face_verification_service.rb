# frozen_string_literal: true

class FaceVerificationService
  attr_reader :current_user, :session, :params

  def initialize(session, params = {})
    @current_user = Current.user
    @session = session
    @params = params
  end

  def self.verify_id_card(id_card_image)
    current_user = Current.user
    return false unless current_user&.user_type == 'student'

    setting = verification_setting

    begin
      id_card_service = FptIdCardService.new(id_card_image)
      id_card_data = id_card_service.call

      student = current_user.student
      success = validate_id_card_data(id_card_data, student)

      if success
        setting.reset_attempts!
        session[:last_face_verification] = Time.current.iso8601
        true
      else
        Rails.logger.error('Xác thực CCCD thất bại: Thông tin CCCD không khớp với thông tin sinh viên')
        false
      end
    rescue FptIdCardError => e
      Rails.logger.error("Lỗi khi xác thực CCCD: #{e.message}")
      false
    end
  end

  def call
    check_face_verification
  end

  def verify_face(image_data)
    return false unless current_user&.user_type == 'student'

    setting = verification_setting

    begin
      face_client = FaceRecognitionClient.new(Rails.application.credentials.fetch(:face_recognition_service_host))
      result = face_client.identify_face_from_data(image_data)

      if result[:success] && result[:student_id].to_i == current_user.student_id
        setting.reset_attempts!
        session[:last_face_verification] = Time.current.iso8601
        true
      else
        setting.increment_failed_attempts!
        Rails.logger.error("Xác thực khuôn mặt thất bại: #{result[:message]}")
        false
      end
    rescue StandardError => e
      setting.increment_failed_attempts!
      Rails.logger.error("Lỗi khi xác thực khuôn mặt: #{e.message}")
      false
    end
  end

  def check_face_verification
    return { status: :ok } unless current_user&.user_type == 'student'
    return { status: :ok } if skip_face_verification?

    setting = verification_setting

    return { status: :ok } unless setting.require_face_verification

    last_verification = session[:last_face_verification]

    if last_verification.present? &&
       Time.current - Time.parse(last_verification) < setting.verification_timeout
      return { status: :ok }
    end

    if setting.requires_id_card_verification?
      {
        status: :unauthorized,
        json: {
          error: 'Yêu cầu xác thực CCCD',
          requires_id_card_verification: true,
          failed_attempts: setting.failed_attempts,
          max_attempts: FaceVerificationSetting::MAX_FAILED_ATTEMPTS
        }
      }
    else
      {
        status: :unauthorized,
        json: {
          error: 'Yêu cầu xác thực khuôn mặt',
          requires_verification: true,
          failed_attempts: setting.failed_attempts,
          max_attempts: FaceVerificationSetting::MAX_FAILED_ATTEMPTS
        }
      }
    end
  end

  def skip_face_verification?
    params[:skip_verification] == 'true'
  end

  def verification_setting
    FaceVerificationSetting.find_or_create_by(admin_user: current_user) do |s|
      s.assign_attributes(FaceVerificationSetting.default_settings)
    end
  end

  def validate_id_card_data(id_card_data, student)
    return false if id_card_data.blank?

    normalize_name(id_card_data[:full_name]) == normalize_name(student.full_name) &&
      id_card_data[:number] == student.id_card_number

    # dob_match = true
    # if student.date_of_birth.present? && id_card[:date_of_birth].present?
    #   dob_match = student.date_of_birth.to_date == id_card[:date_of_birth].to_date
    # end

    # gender_match = true
    # if student.gender.present? && id_card[:gender].present?
    #   gender_match = student.gender.downcase == id_card[:gender].downcase
    # end

    # Rails.logger.info("ID Card validation results - Name: #{name_match}, DOB: #{dob_match}, Gender: #{gender_match}")

    # name_match && dob_match && gender_match
  end

  def normalize_name(name)
    return '' if name.blank?

    name.to_s.downcase.strip.gsub(/\s+/, ' ')
  end
end
