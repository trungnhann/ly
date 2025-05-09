# app/controllers/api/v1/auth/sessions_controller.rb
module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        include JwtAuthenticatable
        include RackSessionsFix

        skip_before_action :verify_authenticity_token, raise: false
        respond_to :json

        # POST /api/v1/auth/sign_in
        def create
          user = AdminUser.find_by(email: sign_in_params[:email].downcase)

          if user&.valid_password?(sign_in_params[:password])
            self.resource = user
            sign_in(resource_name, resource)
            unless user.face_verification_setting
              user.create_face_verification_setting(FaceVerificationSetting.default_settings)
            end

            respond_with(resource)
          else
            render json: { status: { code: 401, message: 'Invalid email or password.' } }, status: :unauthorized
          end
        end

        # DELETE /api/v1/auth/sign_out
        def destroy
          authenticate_user!

          if current_user
            sign_out(current_user)
            render json: { status: { code: 200, message: 'Logged out successfully.' } }, status: :ok
          else
            render json: { status: { code: 401, message: 'Unauthorized' } }, status: :unauthorized
          end
        rescue JWT::DecodeError, ActiveRecord::RecordNotFound
          render json: { status: { code: 401, message: 'Unauthorized' } }, status: :unauthorized
        end

        # POST /api/v1/auth/sign_up
        def register
          user = AdminUser.new(sign_up_params)

          if user.save
            self.resource = user
            sign_in(resource_name, resource)
            respond_with(resource)
          else
            render json: {
              status: { code: 422, message: 'Sign up failed.', errors: user.errors.full_messages }
            }, status: :unprocessable_entity
          end
        end

        protected

        def sign_in_params
          params.expect(user: %i[email password])
        end

        def sign_up_params
          params.expect(user: %i[email password password_confirmation user_type])
        end

        private

        def respond_with(resource, _opts = {})
          token = request.env['warden-jwt_auth.token']
          render json: {
            status: { code: 200, message: 'Logged in successfully.' },
            data: {
              token: token,
              user: AdminUserSerializer.new(resource).serializable_hash[:data][:attributes]
            }
          }, status: :ok
        end

        def respond_to_on_destroy
          head :no_content
        end
      end
    end
  end
end
