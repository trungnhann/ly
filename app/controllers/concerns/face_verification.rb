module FaceVerification
  extend ActiveSupport::Concern

  included do
    before_action :check_face_verification, if: :requires_face_verification?
  end

  private

  def check_face_verification
    result = FaceVerificationService.new(session, params).call

    return unless result[:status] != :ok

    render json: result[:json], status: result[:status]
  end

  def requires_face_verification?
    action_name == 'show' && controller_name == 'certificates'
  end

  def verify_face(image_data, is_disable:)
    FaceVerificationService.new(session, params).verify_face(image_data, is_disable)
  end
end
