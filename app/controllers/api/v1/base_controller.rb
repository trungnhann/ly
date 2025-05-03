module Api
  module V1
    class BaseController < ApplicationController
      skip_before_action :verify_authenticity_token, if: -> { request.format.json? }
      include JwtAuthenticatable
      before_action :authenticate_user!

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

      def json_response(resource, serializer_class, options = {})
        serializer_options = {}

        if params[:include].present?
          includes = params[:include].split(',').map(&:strip)
          serializer_options[:include] = includes
        elsif options[:include].present?
          serializer_options[:include] = options[:include]
        end

        serializer_options.merge!(options.except(:per_page, :include))

        if resource.respond_to?(:to_a) && !resource.is_a?(ApplicationRecord)
          # Xử lý filter
          filtered_collection = apply_filters(resource)

          # Xử lý phân trang
          page = params[:page] || DEFAULT_PAGE
          per_page = params[:per_page] || options[:per_page] || PER_PAGE

          pagy_data, records = paginate(filtered_collection, page: page, per_page: per_page)

          # Thêm metadata phân trang
          serializer_options[:meta] ||= {}
          serializer_options[:meta].merge!({
                                             current_page: pagy_data[:page],
                                             total_pages: pagy_data[:pages],
                                             total_count: pagy_data[:count],
                                             per_page: pagy_data[:items]
                                           })

          # Trả về kết quả dạng JSON:API cho collection
          render json: serializer_class.new(records, serializer_options).serializable_hash
        else
          status = options[:status] || :ok
          render json: serializer_class.new(resource, serializer_options).serializable_hash, status: status
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

      def error_response(exception, message, status)
        response = {
          message: message,
          errors: exception.respond_to?(:record) ? exception.record.errors.full_messages : exception.message
        }

        response[:backtrace] = exception.backtrace if Rails.env.development?
        render json: response, status: status, content_type: 'application/json'
      end

      def paginate(collection, page: DEFAULT_PAGE, per_page: PER_PAGE)
        count = collection.count
        pages = (count.to_f / per_page).ceil

        offset = (page.to_i - 1) * per_page.to_i

        records = collection.offset(offset).limit(per_page)

        pagy_data = {
          count: count,
          page: page.to_i,
          items: per_page.to_i,
          pages: pages
        }

        [pagy_data, records]
      end

      # Phương thức xử lý filter dựa trên model scopes
      def apply_filters(collection)
        return collection if params[:filter].blank?

        filtered = collection

        params[:filter].each do |field, value|
          next if value.blank?

          filter_method = "filter_by_#{field}"
          filtered = filtered.public_send(filter_method, value) if filtered.respond_to?(filter_method)
        end

        filtered
      end
    end
  end
end
