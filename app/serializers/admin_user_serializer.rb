class AdminUserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :user_type, :created_at, :updated_at
end
