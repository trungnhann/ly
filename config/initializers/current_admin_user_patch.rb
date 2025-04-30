ActiveSupport::Reloader.to_prepare do
  ActiveAdmin::BaseController.class_eval do
    before_action { Current.user = current_admin_user }
  end
end
