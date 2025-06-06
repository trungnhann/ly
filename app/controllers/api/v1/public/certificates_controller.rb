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

          render json: CertificateSerializer.new(@certificate).serializable_hash, status: :ok
        end
      end
    end
  end
end
