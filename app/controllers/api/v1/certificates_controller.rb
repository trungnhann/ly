module Api
  module V1
    class CertificatesController < BaseController
      load_and_authorize_resource
      include FaceVerification

      def index
        result = CertificatesService.new.index(params)
        render json: result[:data], status: result[:status]
      end

      def show
        result = CertificatesService.new.show(@certificate)
        render json: result[:data], status: result[:status]
      end

      def verify_face_authentication
        image = params[:image]
        return render json: { error: 'Vui lòng tải lên ảnh để xác thực' }, status: :unprocessable_entity if image.blank?

        image_data = image.read
        if verify_face(image_data)
          render json: { success: true, message: 'Xác thực khuôn mặt thành công' }
        else
          render json: { success: false, error: 'Xác thực khuôn mặt thất bại' }, status: :unauthorized
        end
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

      private

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
