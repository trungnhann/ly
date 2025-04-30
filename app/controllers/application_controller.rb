class ApplicationController < ActionController::Base
  include ActionController::Helpers
  include Devise::Controllers::Helpers
  devise_group :user, contains: [:admin_user]
end
