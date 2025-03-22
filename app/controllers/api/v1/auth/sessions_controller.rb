# frozen_string_literal: true

module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        include RackSessionsFix
        respond_to :json

        def create
          user = AdminUser.find_by(email: sign_in_params[:email])

          if user&.valid_password?(sign_in_params[:password])
            self.resource = user
            sign_in(resource_name, resource)
            respond_with(resource)
          else
            render json: {
              status: {
                code: 401,
                message: 'Invalid email or password.'
              }
            }, status: :unauthorized
          end
        end

        protected

        def sign_in_params
          params.require(:user).permit(:email, :password)
        end

        private

        def respond_with(resource, _opt = {})
          @token = request.env['warden-jwt_auth.token']
          headers['Authorization'] = @token

          render json: {
            status: {
              code: 200,
              message: 'Logged in successfully.'
            },
            data: {
              token: @token,
              user: AdminUserSerializer.new(resource).serializable_hash[:data][:attributes]
            }
          }, status: :ok
        end

        def respond_to_on_destroy
          if request.headers['Authorization'].present?
            jwt_payload = JWT.decode(request.headers['Authorization'].split.last,
                                     Rails.application.credentials.devise_jwt_secret_key!).first

            current_user = AdminUser.find(jwt_payload['sub'])
          end

          if current_user
            render json: {
              status: 200,
              message: 'Logged out successfully.'
            }, status: :ok
          else
            render json: {
              status: 401,
              message: "Couldn't find an active session."
            }, status: :unauthorized
          end
        end
      end
    end
  end
end
