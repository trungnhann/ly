module FaceVerification
  extend ActiveSupport::Concern

  included do
    before_action :check_face_verification, if: :requires_face_verification?
  end

  private

  def check_face_verification
    return unless current_user&.user_type == 'student'
    return if skip_face_verification?

    setting = FaceVerificationSetting.find_or_create_by(admin_user: current_user) do |s|
      s.assign_attributes(FaceVerificationSetting.default_settings)
    end

    return unless setting.require_face_verification

    last_verification = session[:last_face_verification]

    if last_verification.present? &&
       Time.current - Time.parse(last_verification) < setting.verification_timeout
      return
    end

    render json: {
      error: 'Yêu cầu xác thực khuôn mặt',
      requires_verification: true
    }, status: :unauthorized
  end

  def requires_face_verification?
    action_name == 'show' && controller_name == 'certificates'
  end

  def skip_face_verification?
    params[:skip_verification] == 'true'
  end

  def verify_face(image_data)
    return false unless current_user&.user_type == 'student'

    begin
      face_client = FaceRecognitionClient.new(Rails.application.credentials.fetch(:face_recognition_service_host))
      result = face_client.identify_face_from_data(image_data)

      if result[:success] && result[:student_id].to_i == current_user.student_id
        session[:last_face_verification] = Time.current.iso8601
        true
      else
        Rails.logger.error("Xác thực khuôn mặt thất bại: #{result[:message]}")
        false
      end
    rescue StandardError => e
      Rails.logger.error("Lỗi khi xác thực khuôn mặt: #{e.message}")
      false
    end
  end
end
