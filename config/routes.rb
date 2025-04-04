Rails.application.routes.draw do
  get '/health' => 'health#check'
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
        collection do
          post :scan_id_card
        end
        member do
          get :metadata, to: 'students#show_metadata'
        end
      end

      resources :certificates do
        resource :metadata, only: %i[show create update destroy], controller: 'certificate_metadata'
      end
    end
  end
end
