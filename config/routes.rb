Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions" }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root "home#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "health#up", as: :health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  namespace :admin do
    root to: "home#index"
    resources :home, only: [ :index ]
    resources :companies do
      member do
        get :switch
      end
    end
    resources :users
    resources :stores
    resources :settings
  end

  namespace :company_area do
    # root to: "home#index"
    root to: "stores#index"
    resources :users, only: [ :new, :create, :index, :edit, :update ]
    resources :stores, only: [ :index, :edit, :update ]
    resources :settings
    resources :home, only: [ :index ]
  end

  scope "store_area/:store_id", as: :store_area, module: :store_area do
    root to: "home#index"
    resources :home, only: [ :index ]
    resources :customers, only: [ :index, :show ]
    resources :cycles, only: [ :index, :show ] do
      collection do
        post :import_cycles
      end
    end
    namespace :financial do
      resources :income_statements do
        member do
          post :import_transactions
        end
        resources :costs
      end
    end
  end
end
