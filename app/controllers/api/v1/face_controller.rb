module Api
  module V1
    class FaceController < BaseController
      before_action :set_face_client

      # POST /api/v1/faces/register
      # Đăng ký khuôn mặt mới
      def register
        student_id = params[:student_id]
        image = params[:image]

        if student_id.blank? || image.blank?
          return render json: { success: false, error: 'Student ID và ảnh là bắt buộc' }, status: :unprocessable_entity
        end

        # Đọc dữ liệu ảnh từ file tải lên
        image_data = image.read

        # Gọi service để đăng ký khuôn mặt
        result = @face_client.register_face_from_data(student_id, image_data)

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

        # Đọc dữ liệu ảnh từ file tải lên
        image_data = image.read

        # Gọi service để nhận diện khuôn mặt
        result = @face_client.identify_face_from_data(image_data)

        if result[:success]
          # Có thể tìm thông tin sinh viên trong database
          # student_data = {}
          # if defined?(Student)
          #   student = Student.find_by(student_id: result[:student_id])
          #   student_data = student.as_json if student
          # end

          render json: {
            success: true,
            message: 'Nhận diện thành công!',
            student_id: result[:student_id],
            confidence: result[:confidence]
            # student_data: student_data
          }, status: :ok
        else
          render json: { success: false, error: result[:message] }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/faces/attendance
      # Sử dụng nhận diện khuôn mặt để điểm danh
      def attendance
        image = params[:image]
        class_id = params[:class_id]

        if image.blank? || class_id.blank?
          return render json: {
            success: false,
            error: 'Vui lòng tải lên ảnh và chọn lớp học'
          }, status: :unprocessable_entity
        end

        # Đọc dữ liệu ảnh từ file tải lên
        image_data = image.read

        # Gọi service để nhận diện khuôn mặt
        result = @face_client.identify_face_from_data(image_data)

        if result[:success]
          attendance_saved = false
          attendance_id = nil

          # Ghi nhận điểm danh vào database
          if defined?(Attendance)
            attendance = Attendance.new(
              student_id: result[:student_id],
              class_id: class_id,
              confidence: result[:confidence],
              attended_at: Time.now
            )
            attendance_saved = attendance.save
            attendance_id = attendance.id if attendance_saved
          end

          response_message = if attendance_saved
                               "Điểm danh thành công cho sinh viên #{result[:student_id]}"
                             else
                               "Nhận diện thành công sinh viên #{result[:student_id]}, nhưng không thể lưu điểm danh"
                             end

          render json: {
            success: true,
            message: response_message,
            student_id: result[:student_id],
            attendance_saved: attendance_saved,
            attendance_id: attendance_id,
            confidence: result[:confidence]
          }, status: :ok
        else
          render json: { success: false, error: result[:message] }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/faces/:id
      # Xóa đăng ký khuôn mặt
      def destroy
        student_id = params[:id]

        if student_id.blank?
          return render json: { success: false, error: 'Student ID là bắt buộc' }, status: :unprocessable_entity
        end

        # Giả sử có method delete_face trong face_client
        result = @face_client.delete_face(student_id)

        if result[:success]
          render json: { success: true, message: 'Xóa khuôn mặt thành công' }, status: :ok
        else
          render json: { success: false, error: result[:message] }, status: :unprocessable_entity
        end
      end

      private

      def set_face_client
        @face_client = FaceRecognitionClient.new(Rails.application.credentials.fetch(:face_recognition_service_host))
      end
    end
  end
end
