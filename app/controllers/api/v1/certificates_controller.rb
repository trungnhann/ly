module Api
  module V1
    class CertificatesController < BaseController
      before_action :set_certificate, only: %i[show update destroy]

      def index
        @certificates = Certificate.all
        json_response(@certificates, CertificateSerializer)
      end

      def show
        json_response(@certificate, CertificateSerializer)
      end

      def create
        @certificate = Certificate.new(certificate_params)
        if @certificate.save
          json_response(@certificate, CertificateSerializer, status: :created)
        else
          render json: { errors: @certificate.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @certificate.update(certificate_params)
          json_response(@certificate, CertificateSerializer)
        else
          render json: { errors: @certificate.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @certificate.destroy
        head :no_content
      end

      private

      def set_certificate
        @certificate = Certificate.find(params[:id])
      end

      def certificate_params
        params.expect(
          certificate: [:code, :title, :certificate_type, :issue_date, :expiry_date, :is_verified, :student_id,
                        { metadata: [
                          :issuer, :description, :image_path,
                          { degree_info: %i[level major specialization grade graduation_year] },
                          { certificate_info: %i[provider field score level] },
                          { certification_info: %i[event achievement duration organizer] }
                        ] }]
        )
      end
    end
  end
end
