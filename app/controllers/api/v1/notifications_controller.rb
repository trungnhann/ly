module Api
  module V1
    class NotificationsController < BaseController
      before_action :set_notification, only: [:mark_as_read]

      def index
        @notifications = current_user.notifications
                                     .order(created_at: :desc)
                                     .page(params[:page])
                                     .per(params[:per_page])

        render json: {
          data: NotificationSerializer.new(@notifications).serializable_hash,
          meta: {
            total_pages: @notifications.total_pages,
            current_page: @notifications.current_page,
            total_count: @notifications.total_count
          }
        }
      end

      def mark_as_read
        @notification.update(is_read: true)
        render json: { message: 'Đã đánh dấu thông báo là đã đọc' }
      end

      private

      def set_notification
        @notification = current_user.notifications.find(params[:id])
      end
    end
  end
end
