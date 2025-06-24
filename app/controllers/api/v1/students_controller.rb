module Api
  module V1
    class StudentsController < BaseController
      load_and_authorize_resource

      def index
        students = Student.all
        students = students.filter_by_code(params[:code]) if params[:code].present?
        students = students.filter_by_id_card_number(params[:id_card_number]) if params[:id_card_number].present?
        json_response(students, StudentSerializer)
      end

      def show
        render json: StudentSerializer.new(@student).serializable_hash, status: :ok
      end

      def show_metadata
        metadata = @student.metadata
        if metadata
          render json: StudentMetadataSerializer.new(metadata).serializable_hash, status: :ok
        else
          render json: { error: 'Metadata not found' }, status: :not_found
        end
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end

      def scan_id_card
        result = FptAi::IdCardVerifyService.call(image_file: params[:image])
        raise StandardError, result.error.to_s unless result.success?

        id_card_data = result.value[:id_card_data]
        student = Student.find_by(id_card_number: id_card_data[:number])

        if student
          json_response(student, StudentSerializer, include: [:certificates])
        else
          render json: {
            error: 'Student not found',
            id_card_data: id_card_data
          }, status: :not_found
        end
      end

      def create
        result = StudentsService.new.create(student_params)
        render json: result[:data] || { errors: result[:errors] }, status: result[:status]
      end

      def update
        result = StudentsService.new.update(@student, student_params)
        render json: result[:data] || { errors: result[:errors] }, status: result[:status]
      end

      def destroy
        result = StudentsService.new.destroy(@student)
        render json: result[:message] ? { message: result[:message] } : { errors: result[:errors] },
               status: result[:status]
      end

      def import
        if params[:file].blank?
          return render json: { error: 'Vui lòng chọn file Excel để import' }, status: :unprocessable_entity
        end

        temp_file = params[:file].tempfile
        result = Students::ImportStudentFromExcelService.call(file_path: temp_file.path)

        if result.success?
          render json: {
            message: result.value[:message],
            imported_count: result.value[:imported_count]
          }, status: :ok
        else
          render json: {
            message: 'Import failed',
            errors: result.error.to_s
          }, status: :unprocessable_entity
        end
      end

      private

      def student_params
        params.expect(
          student: %i[code full_name id_card_number email avatar
                      phone major specialization address]
        )
      end
    end
  end
end
