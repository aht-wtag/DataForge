require "sidekiq/web"

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => "/sidekiq", as: :sidekiq_web
  end

  devise_for :users

  get "check_email", to: "email_check#show"

  root "dashboard#index"

  namespace :admin do
    resources :users, only: [:index, :show] do
      member do
        patch :update_role
      end
    end
  end

  resources :adapters, except: [:destroy] do
    member do
      patch :archive
    end

    resources :endpoints, except: [:destroy] do
      resources :transformation_rules, except: [:destroy]
    end

    resources :credentials
    resources :job_schedules, except: [:destroy]
  end
end
