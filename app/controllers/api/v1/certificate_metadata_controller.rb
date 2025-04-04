module Api
  module V1
    class CertificateMetadataController < BaseController
      before_action :set_certificate_metadata, only: %i[show update destroy]

      def index
        @certificate_metadata = CertificateMetadata.all
        json_response(@certificate_metadata, CertificateMetadataSerializer)
      end

      def show
        json_response(@certificate_metadata, CertificateMetadataSerializer)
      end

      def create
        @certificate_metadata = CertificateMetadata.new(certificate_metadata_params)
        if @certificate_metadata.save
          json_response(@certificate_metadata, CertificateMetadataSerializer, status: :created)
        else
          render json: { errors: @certificate_metadata.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @certificate_metadata.update(certificate_metadata_params)
          json_response(@certificate_metadata, CertificateMetadataSerializer)
        else
          render json: { errors: @certificate_metadata.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @certificate_metadata.destroy
        head :no_content
      end

      private

      def set_certificate_metadata
        @certificate_metadata = CertificateMetadata.find(params[:id])
      end

      def certificate_metadata_params
        params.expect(certificate_metadata: %i[certificate_id certificate_type])
      end
    end
  end
end
