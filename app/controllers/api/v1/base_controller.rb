module Api
  module V1
    class BaseController < ApplicationController
      skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

      include ActionController::MimeResponds
      include JwtAuthenticatable
      include Pagy::Backend

      before_action :authenticate_user!
      before_action :set_current_session
      before_action :set_default_pagination
      include FaceVerification

      DEFAULT_PAGE = 1
      PER_PAGE = 10

      rescue_from StandardError, with: :handle_error
      rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
      rescue_from ActionController::UnknownFormat, with: :handle_unknown_format
      rescue_from ActiveRecord::RecordNotUnique, with: :handle_conflict
      rescue_from ActionController::ParameterMissing, with: :handle_missing_param
      rescue_from JWT::DecodeError, with: :handle_jwt_error
      rescue_from JWT::ExpiredSignature, with: :handle_token_expired
      rescue_from CanCan::AccessDenied, with: :handle_forbidden

      def json_response(resource, serializer_class, options = {})
        serializer_options = {}

        if params[:include].present?
          includes = params[:include].split(',').map(&:strip)
          serializer_options[:include] = includes
        elsif options[:include].present?
          serializer_options[:include] = options[:include]
        end

        serializer_options.merge!(options.except(:per_page, :include))

        is_collection = resource.is_a?(Enumerable) && !resource.is_a?(ApplicationRecord)

        if is_collection
          pagy_data, records = paginate(resource)

          serializer_options[:meta] ||= {}
          serializer_options[:meta].merge!({
                                             current_page: pagy_data.page,
                                             total_pages: pagy_data.pages,
                                             total_count: pagy_data.count
                                           })

          render json: serializer_class.new(records, serializer_options).serializable_hash
        else
          status = options[:status] || :ok
          render json: serializer_class.new(resource).serializable_hash, status: status
        end
      end

      def handle_error(exception, status = :unprocessable_entity)
        error_response(exception, 'An unexpected error occurred', status)
      end

      def handle_not_found(exception)
        error_response(exception, exception.message, :not_found)
      end

      def handle_missing_param(exception)
        error_response(exception, "Missing required parameter: #{exception.param}", :bad_request)
      end

      def handle_validation_error(exception)
        error_response(exception, 'Validation failed', :unprocessable_entity)
      end

      def handle_conflict(exception)
        error_response(exception, 'A conflict occurred while processing this resource', :conflict)
      end

      def handle_forbidden(exception)
        error_response(exception, exception.message, :forbidden)
      end

      def handle_bad_request(exception)
        error_response(exception, exception.message, :bad_request)
      end

      def handle_jwt_error(exception)
        error_response(exception, 'Invalid token', :unauthorized)
      end

      def handle_token_expired(exception)
        error_response(exception, 'Token has expired', :unauthorized)
      end

      def handle_unknown_format(exception)
        error_response(exception, 'Unsupported format requested', :not_acceptable)
      end

      private

      def set_current_session
        Current.session = session
      end

      def set_default_pagination
        @default_page = AppSetting.get('default_page', 1)
        @default_per_page = AppSetting.get('DEFAULT_PER_PAGE', 10)
      end

      def paginate(collection)
        page = params[:page].presence || @default_page.to_i
        per_page = params[:per_page].presence || @default_per_page.to_i

        pagy_object, paginated_collection = pagy(collection, limit: per_page, page: page)
        [pagy_object, paginated_collection]
      end

      def error_response(exception, message, status)
        response = {
          message: message,
          errors: exception.respond_to?(:record) ? exception.record.errors.full_messages : exception.message
        }

        response[:backtrace] = exception.backtrace if Rails.env.development?
        render json: response, status: status, content_type: 'application/json'
      end

      # # Phương thức xử lý filter dựa trên model scopes
      # def apply_filters(collection)
      #   return collection if params[:filter].blank?
      #
      #   filtered = collection
      #
      #   params[:filter].each do |field, value|
      #     next if value.blank?
      #
      #     filter_method = "filter_by_#{field}"
      #     filtered = filtered.public_send(filter_method, value) if filtered.respond_to?(filter_method)
      #   end
      #
      #   filtered
      # end
    end
  end
end
