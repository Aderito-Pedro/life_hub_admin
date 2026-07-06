Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  root "dashboard#show"
  get "dashboard", to: "dashboard#show"

  resources :users, only: [ :index, :show, :update ]
  resources :categories, only: [ :index, :new, :create, :edit, :update ]
  resources :products, only: [ :index, :new, :create, :edit, :update ]
  resources :orders, only: [ :index, :show ]
  resources :payments, only: [] do
    member { post :refund }
  end
  resources :audit_logs, only: [ :index ]
end
