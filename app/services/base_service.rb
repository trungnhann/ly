class BaseService
  class << self
    def call(*)
      new(*).call
    end

    private

    def handle_response(response)
      case response.code
      when 200
        handle_success(response)
      when 401
        handle_unauthorized
      when 403
        handle_forbidden
      when 404
        handle_not_found
      when 429
        handle_rate_limit
      else
        handle_error(response)
      end
    end

    def handle_success(response)
      response.parsed_response
    end

    def handle_unauthorized
      raise ServiceError, 'Unauthorized access'
    end

    def handle_forbidden
      raise ServiceError, 'Access forbidden'
    end

    def handle_not_found
      raise ServiceError, 'Resource not found'
    end

    def handle_rate_limit
      raise ServiceError, 'Rate limit exceeded'
    end

    def handle_error(response)
      raise ServiceError, "Service request failed with status #{response.code}"
    end

    def log_error(error)
      Rails.logger.error "[#{self.class.name}] Error: #{error.message}"
      Rails.logger.error error.backtrace.join("\n")
    end
  end
end

class ServiceError < StandardError; end
