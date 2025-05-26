class AppSettingsSerializer < BaseSerializer
  attributes :id, :key_name, :key_value, :description, :created_at, :updated_at
end
