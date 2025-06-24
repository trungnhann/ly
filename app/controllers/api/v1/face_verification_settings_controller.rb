module Api
  module V1
    class FaceVerificationSettingsController < BaseController
      before_action :authenticate_user!
      before_action :set_face_verification_setting

      def show
        render json: {
          require_face_verification: @face_verification_setting.require_face_verification
        }, status: :ok
      end

      def update
        if @face_verification_setting.update(face_verification_setting_params)

          session[:last_face_verification] = nil if @face_verification_setting.require_face_verification

          render json: {
            require_face_verification: @face_verification_setting.require_face_verification
          }, status: :ok
        else
          render json: { errors: @face_verification_setting.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_face_verification_setting
        @face_verification_setting = current_user.face_verification_setting ||
                                     current_user.create_face_verification_setting
      end

      def face_verification_setting_params
        params.expect(
          face_verification_setting: [:require_face_verification]
        )
      end
    end
  end
end
