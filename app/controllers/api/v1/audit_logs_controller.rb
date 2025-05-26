module Api
  module V1
    class AuditLogsController < BaseController
      load_and_authorize_resource
      def index
        json_response(@audit_logs.order(created_at: :desc), AuditLogSerializer)
      end
    end
  end
end
