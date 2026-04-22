Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  root "home#index"

  resources :courses, only: [:index, :show] do
    post :enroll, on: :member
    resources :lessons, only: [:index, :show] do
      get :watch, on: :member
      post :record_view, on: :member
    end
  end

  resources :payments, only: [:new] do
    post :verify, on: :member
  end
  post "payments/webhook", to: "payments#webhook"

  resources :device_sessions, only: [:index, :destroy]
  get "profile", to: "profile#show"
  patch "profile", to: "profile#update"
  get "dashboard", to: "dashboard#index"
  get "my_payments", to: "my_payments#index"

  namespace :admin do
    get "dashboard", to: "dashboard#index"
    resources :courses do
      resources :lessons
    end
    resources :users, only: [:index, :show]
    resources :payments, only: [:index]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
