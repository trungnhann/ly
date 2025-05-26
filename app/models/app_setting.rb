# == Schema Information
#
# Table name: app_settings
#
#  id          :bigint           not null, primary key
#  description :string
#  key_name    :string           not null, indexed
#  key_value   :string           not null
#  metadata    :jsonb
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_app_settings_on_key_name  (key_name) UNIQUE
#
class AppSetting < ApplicationRecord
  include Auditable

  validates :key_name, presence: true, uniqueness: true
  validates :key_value, presence: true

  def self.get(key_name, default = nil)
    setting = find_by(key_name:)
    return default unless setting

    setting.key_value
  end
end
