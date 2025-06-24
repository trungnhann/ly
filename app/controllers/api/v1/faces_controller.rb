module Api
  module V1
    class FacesController < BaseController
      before_action :set_face_client
      skip_before_action :check_face_verification, only: [:register]
      before_action :set_face_verification_setting, only: %i[verify_face_authentication check_verification_status
                                                             verify_id_card]

      # POST /api/v1/faces/register
      # Đăng ký khuôn mặt mới
      def register
        student_id = params[:student_id]
        image = params[:image]

        if student_id.blank? || image.blank?
          return render json: { success: false, error: 'Student ID và ảnh là bắt buộc' }, status: :unprocessable_entity
        end

        result = @face_client.register_face_from_data(student_id, image.read)

        if result[:success]
          render json: { success: true, message: 'Đăng ký khuôn mặt thành công!' }, status: :created
        else
          render json: { success: false, error: result[:message] }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/faces/identify
      # Nhận diện khuôn mặt từ ảnh gửi lên
      def identify
        image = params[:image]

        if image.blank?
          return render json: { success: false, error: 'Vui lòng tải lên ảnh để nhận diện' },
                        status: :unprocessable_entity
        end

        result = @face_client.identify_face_from_data(image.read)

        if result[:success]
          if defined?(Student)
            student = Student.find(result[:student_id])
            student_data = student&.as_json
          end

          render json: {
            success: true,
            message: 'Nhận diện thành công!',
            student_id: result[:student_id],
            confidence: result[:confidence],
            student_data:
          }, status: :ok
        else
          render json: { success: false, error: result[:message] }, status: :unprocessable_entity
        end
      end

      def check_verification_status
        if @verification_setting.requires_id_card_verification?
          render json: {
            success: true,
            verification_type: 'id_card',
            message: 'Yêu cầu xác thực CCCD',
            failed_attempts: @verification_setting.failed_attempts,
            max_attempts: FaceVerificationSetting::MAX_FAILED_ATTEMPTS
          }
        else
          render json: {
            success: true,
            verification_type: 'face',
            message: 'Yêu cầu xác thực khuôn mặt',
            failed_attempts: @verification_setting.failed_attempts,
            max_attempts: FaceVerificationSetting::MAX_FAILED_ATTEMPTS
          }
        end
      end

      def verify_face_authentication
        image = params[:image]
        return render json: { error: 'Vui lòng tải lên ảnh để xác thực' }, status: :unprocessable_entity if image.blank?

        is_disable = params[:is_disable] || false
        image_data = image.read
        if verify_face(image_data, is_disable:)
          render json: { success: true, message: 'Xác thực khuôn mặt thành công' }
        else
          requires_id_card = @verification_setting.requires_id_card_verification?
          render json: {
            success: false,
            error: 'Xác thực khuôn mặt thất bại',
            failed_attempts: @verification_setting.failed_attempts,
            max_attempts: FaceVerificationSetting::MAX_FAILED_ATTEMPTS,
            requires_id_card_verification: requires_id_card
          }, status: :unauthorized
        end
      end

      def destroy
        student_id = params[:id]

        if student_id.blank?
          return render json: { success: false, error: 'Student ID là bắt buộc' }, status: :unprocessable_entity
        end

        if defined?(Student) && !Student.exists?(student_id)
          return render json: { success: false, error: 'Không tìm thấy sinh viên với ID này' }, status: :not_found
        end

        result = @face_client.delete_face(student_id)

        if result[:success]
          session[:last_face_verification] = nil
          render json: {
            success: true,
            message: 'Xóa khuôn mặt thành công',
            student_id: student_id
          }, status: :ok
        else
          render json: {
            success: false,
            error: result[:message] || 'Không thể xóa khuôn mặt'
          }, status: :unprocessable_entity
        end
      end

      def verify_id_card
        image = params[:image]

        if image.blank?
          return render json: {
            success: false,
            error: 'Vui lòng tải lên ảnh CCCD/CMND để xác thực'
          }, status: :unprocessable_entity
        end

        result = FptAi::IdCardVerifyService.call(image_file: image)
        if result
          @verification_setting.reset_attempts!
          render json: {
            success: true,
            message: 'Xác thực CCCD/CMND thành công'
          }, status: :ok
        else
          render json: {
            success: false,
            error: 'Xác thực CCCD/CMND thất bại. Vui lòng đảm bảo ảnh rõ nét và thông tin trùng khớp.'
          }, status: :unauthorized
        end
      end

      private

      def set_face_client
        @face_client = FaceRecognitionClient.new(Rails.application.credentials.fetch(:face_recognition_service_host))
      end

      def set_face_verification_setting
        @verification_setting = FaceVerificationSetting.find_by(admin_user: Current.user)
      end
    end
  end
end
