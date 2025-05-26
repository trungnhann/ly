# == Schema Information
#
# Table name: notifications
#
#  id                :bigint           not null, primary key
#  content           :text             not null
#  is_read           :boolean          default(FALSE), indexed
#  notification_type :string           not null, indexed
#  title             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  admin_user_id     :bigint           not null, indexed
#
# Indexes
#
#  index_notifications_on_admin_user_id      (admin_user_id)
#  index_notifications_on_is_read            (is_read)
#  index_notifications_on_notification_type  (notification_type)
#
# Foreign Keys
#
#  fk_rails_...  (admin_user_id => admin_users.id)
#
class NotificationSerializer < BaseSerializer
  attributes :id, :title, :content, :notification_type, :is_read, :created_at, :updated_at
end
