Rails.application.routes.draw do
  resources :students
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
      resources :students do
        resource :metadata, only: %i[show create update destroy], controller: 'student_metadata'
        member do
          get :metadata, to: 'students#show_metadata'
        end
      end
    end
  end
end
