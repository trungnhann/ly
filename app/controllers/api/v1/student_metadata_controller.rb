module Api
  module V1
    class StudentMetadataController < BaseController
      before_action :set_student
      before_action :set_metadata, only: %i[show update destroy]

      def show
        json_response(@metadata, StudentMetadataSerializer)
      end

      def create
        @metadata = StudentMetadata.new(metadata_params.merge(student_id: @student.id.to_s))

        if @metadata.save
          json_response(@metadata, StudentMetadataSerializer, status: :created)
        else
          render json: { errors: @metadata.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @metadata.update(metadata_params)
          json_response(@metadata, StudentMetadataSerializer)
        else
          render json: { errors: @metadata.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @metadata.destroy
        head :no_content
      end

      private

      def set_student
        @student = Student.find(params[:student_id])
      end

      def set_metadata
        @metadata = @student.metadata
        render json: { error: 'Metadata not found' }, status: :not_found unless @metadata
      end

      def metadata_params
        params.expect(
          metadata: [:avatar,
                     :id_card_front,
                     :id_card_back,
                     { id_card: %i[address issue_date issue_place expiry_date] }]
        )
      end

      rescue_from Mongoid::Errors::DocumentNotFound, with: :handle_not_found
      rescue_from Mongoid::Errors::Validations, with: :handle_validation_error

      def paginate(collection, page: DEFAULT_PAGE, per_page: PER_PAGE)
        count = collection.count
        pages = (count.to_f / per_page).ceil
        records = collection.skip((page.to_i - 1) * per_page.to_i).limit(per_page)

        pagy_data = {
          count: count,
          page: page.to_i,
          items: per_page.to_i,
          pages: pages
        }

        [pagy_data, records]
      end
    end
  end
end
