Rails.application.routes.draw do
  get '/health' => 'health#check'
  # ── JSON API ──
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      devise_for :admin_users,
                 path: 'auth',
                 controllers: {
                   sessions: 'api/v1/auth/sessions',
                   passwords: 'api/v1/auth/passwords'
                 },
                 path_names: {
                   sign_in: 'sign_in',
                   sign_out: 'sign_out'
                 },
                 skip: %i[registrations confirmations]

      devise_scope :admin_user do
        post 'auth/sign_up', to: 'auth/sessions#register'
        delete 'auth/sign_out', to: 'auth/sessions#destroy'
      end

      namespace :auth do
        get 'verify_token', to: 'validations#verify_token'
      end

      resources :students do
        resource :metadata, controller: 'student_metadata'
        collection do
          post :scan_id_card
          post :import
        end
        member { get :metadata, to: 'students#show_metadata' }
      end

      resources :certificates do
        resource :metadata, controller: 'certificate_metadata'
        collection do
          get :find_by_code
        end
        member do
          patch :toggle_public
        end
      end

      resources :notifications do
        member do
          post :mark_as_read
        end
      end

      resources :app_settings, only: %i[index show update create destroy]

      resources :audit_logs, only: %i[index]

      resources :faces do
        collection do
          post :register
          post :identify
          post :verify_face_authentication
          post :verify_id_card
          get :check_verification_status
        end
        member do
          delete :destroy
        end
      end

      resource :face_verification_setting, only: %i[show update]

      namespace :public do
        get 'certificates/:code', to: 'certificates#lookup', as: 'certificate'
        # Thêm route mới cho tìm kiếm theo CCCD và mã chứng chỉ
        get 'search', to: 'certificates#search', as: 'certificate_search'
      end
    end
  end
end
