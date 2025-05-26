module Api
  module V1
    class AppSettingsController < BaseController
      load_and_authorize_resource
      def index
        json_response(@app_settings, AppSettingsSerializer)
      end

      def show
        json_response(@app_setting, AppSettingsSerializer)
      end

      def create
        json_response(@app_setting, AppSettingsSerializer, status: :created) if @app_setting.save!
      end

      def update
        json_response(@app_setting, AppSettingsSerializer) if @app_setting.update!(app_setting_params)
      end

      def destroy
        @app_setting.destroy
        head :no_content
      end

      private

      def app_setting_params
        params.expect(app_setting: %i[key_name key_value description])
      end
    end
  end
end
