# frozen_string_literal: true

class FaceVerificationService
  attr_reader :current_user, :session, :params, :verification_setting

  def initialize(session, params = {})
    @current_user = Current.user
    @session = session
    @params = params
    @verification_setting = FaceVerificationSetting.find_by(admin_user: Current.user)
  end

  def call
    check_face_verification
  end

  def verify_face(image_data, is_disable)
    return false unless current_user&.user_type == 'student'

    begin
      face_client = FaceRecognitionClient.new(Rails.application.credentials.fetch(:face_recognition_service_host))
      result = face_client.identify_face_from_data(image_data)

      if result[:success] && result[:student_id].to_i == current_user.student_id
        verification_setting.reset_attempts!
        session[:last_face_verification] = if is_disable
                                             nil
                                           else
                                             Time.current.iso8601
                                           end
        true
      else
        verification_setting.increment_failed_attempts!
        Rails.logger.error("Xác thực khuôn mặt thất bại: #{result[:message]}")
        false
      end
    rescue StandardError => e
      verification_setting.increment_failed_attempts!
      Rails.logger.error("Lỗi khi xác thực khuôn mặt: #{e.message}")
      false
    end
  end

  def check_face_verification
    return { status: :ok } unless current_user&.user_type == 'student'

    return { status: :ok } unless verification_setting.require_face_verification

    last_verification = session[:last_face_verification]

    if last_verification.present? &&
       Time.current - Time.parse(last_verification) < verification_setting.verification_timeout
      return { status: :ok }
    end

    if verification_setting.requires_id_card_verification?
      {
        status: :unauthorized,
        json: {
          error: 'Yêu cầu xác thực CCCD',
          requires_id_card_verification: true,
          failed_attempts: verification_setting.failed_attempts,
          max_attempts: FaceVerificationSetting::MAX_FAILED_ATTEMPTS
        }
      }
    else
      {
        status: :unauthorized,
        json: {
          error: 'Yêu cầu xác thực khuôn mặt',
          requires_verification: true,
          failed_attempts: verification_setting.failed_attempts,
          max_attempts: FaceVerificationSetting::MAX_FAILED_ATTEMPTS
        }
      }
    end
  end
end
