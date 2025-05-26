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
class Notification < ApplicationRecord
  belongs_to :admin_user

  validates :title, presence: true
  validates :content, presence: true
  validates :notification_type, presence: true

  enum :notification_type, {
    certificate_expiring: 'certificate_expiring'
  }

  scope :unread, -> { where(is_read: false) }
  scope :by_type, ->(type) { where(notification_type: type) }
end
