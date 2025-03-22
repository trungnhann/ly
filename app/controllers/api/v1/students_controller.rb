module Api
  module V1
    class StudentsController < BaseController
      before_action :set_student, only: %i[show update destroy show_metadata]

      # GET /students
      def index
        @students = Student.all
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
        params.require(:student).permit(:code, :full_name, :id_card_number, :email)
      end

      def metadata_params
        return nil if params[:student][:metadata].blank?

        params.require(:student).require(:metadata).permit(
          id_card: %i[address issue_date issue_place expiry_date],
          additional_info: %i[address phone nationality]
        ).to_h
      end

      def handle_metadata
        return if metadata_params.blank?

        begin
          metadata = @student.metadata || StudentMetadata.new(student_id: @student.id.to_s)
          metadata.id_card = metadata_params[:id_card]
          metadata.additional_info = metadata_params[:additional_info]

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
    end
  end
end
