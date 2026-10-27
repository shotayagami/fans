Rails.application.routes.draw do
  devise_for :users

  root "creators#index"
  resources :creators, only: %i[index show]
  resources :posts, only: :show
  resources :plans, only: [] do
    resource :checkout, only: :create
  end
  resources :subscriptions, only: %i[index destroy]

  namespace :studio do
    root "plans#index"
    resources :plans, except: %i[show destroy]
    resources :posts, except: :show
    resource :enrollment, only: %i[new create]
    resource :connect, only: %i[show create]
    resources :ledger_entries, only: :index
  end

  namespace :admin do
    resources :subscriptions, only: :index
  end

  post "webhooks/stripe", to: "webhooks/stripe#create"

  get "up" => "rails/health#show", as: :rails_health_check
end
