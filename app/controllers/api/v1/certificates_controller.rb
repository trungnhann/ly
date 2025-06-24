module Api
  module V1
    class CertificatesController < BaseController
      load_and_authorize_resource except: [:create]
      def index
        certificates = Certificate.accessible_by(Ability.new(Current.user))
        certificates = certificates.where(student_id: params[:student_id]) if params[:student_id].present?
        if params[:certificate_type].present?
          certificates = certificates.where(certificate_type: params[:certificate_type])
        end

        json_response(certificates, CertificateSerializer)
      end

      def show
        result = CertificatesService.new.show(@certificate)
        render json: result[:data], status: result[:status]
      end

      def create
        result = CertificatesService.new.create(certificate_params)
        render json: result[:data] || { errors: result[:errors] }, status: result[:status]
      end

      def update
        result = CertificatesService.new.update(@certificate, certificate_params)
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
        result = CertificatesService.new.destroy(@certificate)
        render json: result[:message] ? { message: result[:message] } : { errors: result[:errors] },
               status: result[:status]
      end

      def toggle_public
        @certificate.update(is_public: !@certificate.is_public)

        response_data = CertificateSerializer.new(@certificate).serializable_hash

        if @certificate.is_public
          public_url = Rails.application.routes.url_helpers.api_v1_public_certificate_url(code: @certificate.code)
          response_data[:data][:attributes][:public_url] = public_url
        end

        render json: response_data, status: :ok
      end

      private

      def certificate_params
        params.expect(
          certificate: [:code, :title, :certificate_type, :issue_date, :expiry_date, :is_verified, :student_code, :file,
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
