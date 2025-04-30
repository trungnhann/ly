module Api
  module V1
    module Auth
      class ValidationsController < ApplicationController
        include JwtAuthenticatable
        before_action :authenticate_user!

        def verify_token
          render json: { status: { code: 200, message: 'Token valid' } }
        end
      end
    end
  end
end
