Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

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
end
