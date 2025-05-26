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
require 'test_helper'

class AppSettingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
