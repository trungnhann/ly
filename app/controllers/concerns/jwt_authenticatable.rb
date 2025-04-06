module JwtAuthenticatable
  extend ActiveSupport::Concern

  included do
    attr_reader :current_user
  end

  private

  def authenticate_user!
    header = request.headers['Authorization']
    header = header.split.last if header
    @decoded = JWT.decode(header, Rails.application.credentials.devise_jwt_secret_key!).first
    @current_user = AdminUser.find(@decoded['sub'])
  end
end
