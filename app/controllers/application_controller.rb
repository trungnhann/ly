class ApplicationController < ActionController::Base
  include ActionController::Helpers
  include Devise::Controllers::Helpers
  devise_group :user, contains: [:admin_user]
  # def authenticate_admin_user!
  #   authenticate_user!
  # end
  # Tạm thời bỏ authentication để kiểm tra giao diện
  # before_action :authenticate_admin_user!

  # protected

  # def authenticate_admin_user!
  #   if request.format.json?
  #     authenticate_api_admin_user!
  #   else
  #     authenticate_web_admin_user!
  #   end
  # end

  # private

  # def authenticate_web_admin_user!
  #   return if current_admin_user

  #   redirect_to new_admin_user_session_path, alert: I18n.t('devise.failure.unauthenticated')
  # end

  # def authenticate_api_admin_user!
  #   return if current_admin_user

  #   if request.headers['Authorization'].present?
  #     begin
  #       token = request.headers['Authorization'].split.last
  #       decoded = JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key!).first
  #       @current_admin_user = AdminUser.find(decoded['sub'])
  #       nil if @current_admin_user
  #     rescue JWT::DecodeError, ActiveRecord::RecordNotFound
  #       render json: { error: I18n.t('devise.failure.invalid') }, status: :unauthorized
  #     end
  #   else
  #     render json: { error: I18n.t('devise.failure.unauthenticated') }, status: :unauthorized
  #   end
  # end
end
