module Api
  module V1
    class FaceController < BaseController
      before_action :set_face_client
      skip_before_action :check_face_verification, only: [:register]

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

      def verify_face_authentication
        image = params[:image]
        return render json: { error: 'Vui lòng tải lên ảnh để xác thực' }, status: :unprocessable_entity if image.blank?

        image_data = image.read
        if verify_face(image_data)
          render json: { success: true, message: 'Xác thực khuôn mặt thành công' }
        else
          render json: { success: false, error: 'Xác thực khuôn mặt thất bại' }, status: :unauthorized
        end
      end

      # DELETE /api/v1/faces/:id
      # Xóa đăng ký khuôn mặt
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
      rescue StandardError => e
        Rails.logger.error("Error deleting face: #{e.message}")
        render json: {
          success: false,
          error: 'Đã xảy ra lỗi khi xóa khuôn mặt'
        }, status: :internal_server_error
      end

      private

      def set_face_client
        @face_client = FaceRecognitionClient.new(Rails.application.credentials.fetch(:face_recognition_service_host))
      end
    end
  end
end
