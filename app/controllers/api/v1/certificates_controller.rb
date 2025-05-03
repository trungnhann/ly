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
        return unless @certificate.save!

        json_response(@certificate, CertificateSerializer, status: :created)
      end

      def update
        return unless @certificate.update!(certificate_params)

        json_response(@certificate, CertificateSerializer)
      end

      def find_by_code
        cert = Certificate.find_by(code: params[:code])

        if cert.present?
          json_response(cert, CertificateSerializer, include: [:student])
        else
          render json: { error: 'Không tìm thấy chứng chỉ với mã đã cung cấp' }, status: :not_found
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
