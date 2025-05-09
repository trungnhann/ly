module Api
  module V1
    class StudentsController < BaseController
      load_and_authorize_resource

      def index
        result = StudentsService.new.index(params)
        render json: result[:data], status: result[:status]
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
        id_card_data = FptIdCardService.call(params[:image])
        student = Student.find_by(id_card_number: id_card_data[:id_card][:number])

        if student
          render json: StudentSerializer.new(student, include: [:certificates]).serializable_hash,
                 status: :ok
        else
          render json: { error: 'Student not found' }, status: :not_found
        end
      rescue ServiceError => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
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

      private

      def student_params
        params.expect(
          student: %i[code full_name id_card_number email avatar
                      metadata_phone metadata_major metadata_specialization]
        )
      end
    end
  end
end
