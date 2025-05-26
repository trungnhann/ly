module Api
  module V1
    module Auth
      class PasswordsController < Devise::PasswordsController
        include JwtAuthenticatable
        include RackSessionsFix

        skip_before_action :verify_authenticity_token, raise: false
        before_action :authenticate_user!
        respond_to :json

        # PUT /api/v1/auth/password
        def update
          @user = current_user

          if @user.update_with_password(password_params)
            @user.jti = SecureRandom.uuid
            @user.save

            render json: {
              success: true,
              status: { code: 200, message: 'Mật khẩu đã được thay đổi thành công.' }
            }, status: :ok
          else
            render json: {
              success: false,
              message: @user.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        private

        def password_params
          params.expect(user: %i[current_password password password_confirmation])
        end
      end
    end
  end
end
