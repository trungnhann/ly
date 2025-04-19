# app/controllers/api/v1/auth/sessions_controller.rb
module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        include JwtAuthenticatable
        skip_before_action :verify_authenticity_token, raise: false
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
          params.expect(user: %i[email password])
        end

        private

        def respond_with(resource, _opts = {})
          token = request.env['warden-jwt_auth.token']
          render json: {
            status: { code: 200, message: 'Logged in successfully.' },
            data: { token: token,
                    user: AdminUserSerializer.new(resource).serializable_hash[:data][:attributes] }
          }, status: :ok
        end

        def respond_to_on_destroy
          head :no_content
        end
      end
    end
  end
end
