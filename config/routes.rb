Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users

  get "check_email", to: "email_check#show"

  root "dashboard#index"
end
