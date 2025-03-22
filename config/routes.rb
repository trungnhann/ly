Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check
  namespace :api do
    namespace :v1 do
      devise_for :admin_users, path: '', path_names: {
                                           sign_in: 'login',
                                           sign_out: 'logout',
                                           registration: 'signup'
                                         },
                               controllers: {
                                 sessions: 'api/v1/auth/sessions',
                                 registrations: 'api/v1/auth/registrations'
                               }
    end
  end
end
