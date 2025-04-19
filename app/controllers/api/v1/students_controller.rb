module Api
  module V1
    class StudentsController < BaseController
      before_action :set_student, only: %i[show update destroy show_metadata]

      def index
        @students = Student.all
        @students = @students.filter_by_code(params[:code]) if params[:code].present?
        @students = @students.filter_by_id_card_number(params[:id_card_number]) if params[:id_card_number].present?
        json_response(@students, StudentSerializer)
      end

      # GET /students/1
      def show
        json_response(@student, StudentSerializer)
      end

      # GET /students/1/metadata
      def show_metadata
        Rails.logger.info "Looking for metadata with student_id: #{@student.id}"

        begin
          metadata = @student.metadata
          if metadata
            Rails.logger.info "Found metadata: #{metadata.inspect}"
            json_response(metadata, StudentMetadataSerializer)
          else
            Rails.logger.warn "No metadata found for student_id: #{@student.id}"
            render json: { error: 'Metadata not found' }, status: :not_found
          end
        rescue StandardError => e
          Rails.logger.error "Error finding metadata: #{e.message}"
          render json: { error: e.message }, status: :internal_server_error
        end
      end

      # POST /students/scan_id_card
      def scan_id_card
        id_card_data = FptIdCardService.call(params[:image])
        student = Student.find_by(id_card_number: id_card_data[:id_card][:number])

        if student
          Rails.logger.info "Found existing student: #{student.id}"
          # update_student_metadata(student)
          json_response(student, StudentSerializer)
        else
          Rails.logger.info "No student found with ID card number: #{id_card_data[:id_card][:number]}"
          raise ActiveRecord::RecordNotFound,
                "Student not found with ID card number: #{id_card_data[:id_card][:number]}"
        end
      rescue ServiceError => e
        Rails.logger.error "Service error: #{e.message}"
        render json: { error: e.message }, status: :unprocessable_entity
      rescue StandardError => e
        Rails.logger.error "Error scanning ID card: #{e.message}"
        render json: { error: e.message }, status: :internal_server_error
      end

      # POST /students
      def create
        @student = Student.new(student_params)

        if @student.save
          handle_metadata
          json_response(@student, StudentSerializer, status: :created)
        else
          render json: { errors: @student.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /students/1
      def update
        if @student.update(student_params)
          handle_metadata
          json_response(@student, StudentSerializer)
        else
          render json: { errors: @student.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /students/1
      def destroy
        @student.destroy!
        head :no_content
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_student
        @student = Student.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def student_params
        params.expect(student: %i[code full_name id_card_number email])
      end

      def metadata_params
        return nil if params[:student][:metadata].blank?

        params.require(:student).require(:metadata).permit(
          :phone,
          :major,
          :specialization,
          id_card: %i[address gender issue_date issue_place expiry_date]
        )
      end

      def handle_metadata
        return if metadata_params.blank?

        begin
          metadata = @student.metadata || StudentMetadata.new(student_id: @student.id.to_s)

          metadata.phone = metadata_params[:phone]
          metadata.major = metadata_params[:major]
          metadata.specialization = metadata_params[:specialization]

          log_action = metadata.new_record? ? 'Creating' : 'Updating'
          Rails.logger.info "#{log_action} metadata with: #{metadata.attributes.inspect}"

          unless metadata.save
            Rails.logger.error "Failed to #{log_action.downcase} metadata: #{metadata.errors.full_messages.join(', ')}"
          end
        rescue StandardError => e
          Rails.logger.error "Failed to handle metadata: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
        end
      end

      def update_student_metadata(student)
        metadata = student.metadata || StudentMetadata.new(student_id: student.id.to_s)
        metadata.save!
      end
    end
  end
end
