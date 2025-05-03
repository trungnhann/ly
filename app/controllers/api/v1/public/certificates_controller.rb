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

          render json: CertificateSerializer.new(@certificate).serializable_hash, status: :ok
        end

        private

        def handle_error(exception, status = :unprocessable_entity)
          error_response(exception, 'An unexpected error occurred', status)
        end

        def handle_not_found(exception)
          error_response(exception, exception.message, :not_found)
        end

        def handle_missing_param(exception)
          error_response(exception, "Missing required parameter: #{exception.param}", :bad_request)
        end

        def handle_unknown_format(exception)
          error_response(exception, 'Unsupported format requested', :not_acceptable)
        end

        def error_response(exception, message, status)
          response = {
            message: message,
            errors: exception.respond_to?(:record) ? exception.record.errors.full_messages : exception.message
          }

          response[:backtrace] = exception.backtrace if Rails.env.development?
          render json: response, status: status, content_type: 'application/json'
        end
      end
    end
  end
end
