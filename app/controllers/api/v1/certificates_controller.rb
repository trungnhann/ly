module Api
  module V1
    class CertificatesController < BaseController
      before_action :set_certificate, only: %i[show update destroy]

      def index
        result = CertificatesService.index(params)
        render json: result[:data], status: result[:status]
      end

      def show
        result = CertificatesService.show(@certificate)
        render json: result[:data], status: result[:status]
      end

      def create
        result = CertificatesService.create(certificate_params)
        render json: result[:data] || { errors: result[:errors] }, status: result[:status]
      end

      def update
        result = CertificatesService.update(@certificate, certificate_params)
        render json: result[:data] || { errors: result[:errors] }, status: result[:status]
      end

      def find_by_code
        result = CertificatesService.find_by(code: params[:code])

        if result[:errors]
          render json: { error: result[:errors].first }, status: result[:status]
        else
          render json: result[:data], status: result[:status]
        end
      end

      def destroy
        result = CertificatesService.destroy(@certificate)
        render json: result[:message] ? { message: result[:message] } : { errors: result[:errors] },
               status: result[:status]
      end

      private

      def set_certificate
        @certificate = Certificate.find(params[:id])
      end

      def certificate_params
        params.expect(
          certificate: [:code, :title, :certificate_type, :issue_date, :expiry_date, :is_verified, :student_id, :file,
                        { metadata: [
                          :issuer, :description,
                          { degree_info: %i[level major specialization grade graduation_year] },
                          { certificate_info: %i[provider field score level] },
                          { certification_info: %i[event achievement duration organizer] }
                        ] }]
        )
      end
    end
  end
end
