module Api
  module V1
    module Public
      class CertificatesController < ApplicationController
        skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

        rescue_from StandardError, with: :handle_error
        rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
        rescue_from ActionController::UnknownFormat, with: :handle_unknown_format
        rescue_from ActionController::ParameterMissing, with: :handle_missing_param

        def lookup
          code = params[:code]
          if code.blank?
            return render json: {
              error: 'Certificate code is required'
            }, status: :bad_request
          end

          @certificate = Certificate.find_by(code: code)

          if @certificate.nil?
            return render json: {
              error: 'Certificate not found'
            }, status: :not_found
          end

          # Kiểm tra xem certificate có phải là public không
          unless @certificate.is_public
            return render json: {
              error: 'Certificate is not public'
            }, status: :forbidden
          end

          render json: PublicCertificateSerializer.new(@certificate).serializable_hash, status: :ok
        end

        def search
          id_card_number = params[:id_card_number]
          certificate_code = params[:certificate_code]

          if id_card_number.blank? || certificate_code.blank?
            return render json: {
              error: 'Số căn cước công dân và mã chứng chỉ là bắt buộc'
            }, status: :bad_request
          end

          student = Student.find_by(id_card_number: id_card_number)

          if student.nil?
            return render json: {
              error: 'Không tìm thấy sinh viên với số căn cước công dân này'
            }, status: :not_found
          end

          certificate = Certificate.find_by(code: certificate_code, student_id: student.id)

          if certificate.nil?
            return render json: {
              error: 'Không tìm thấy chứng chỉ phù hợp với thông tin đã cung cấp'
            }, status: :not_found
          end

          # unless certificate.is_public
          #   return render json: {
          #     error: 'Chứng chỉ này không được công khai'
          #   }, status: :forbidden
          # end

          render json: PublicCertificateSerializer.new(certificate).serializable_hash, status: :ok
        end
      end
    end
  end
end
