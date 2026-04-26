Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Public / villager-facing
  resource :session, only: %i[new create destroy], controller: "sessions" do
    get :callback, on: :collection
    post :callback, on: :collection
  end
  resource :profile, only: %i[edit update], controller: "profiles" do
    resources :profile_answers, only: %i[update], controller: "profile_answers"
  end
  root "profiles#index"

  # Public profile page — must be after all other top-level routes
  get "/:id", to: "profiles#show", as: :public_profile

  mount MissionControl::Jobs::Engine, at: "/town_hall/jobs"

  namespace :town_hall do
    resource :session, only: %i[new create destroy]
    resource :password_reset, only: %i[new create edit update]
    resources :stewards, only: %i[index new create destroy]
    resource :profile, only: %i[edit update]
    resources :configurations
    resources :profile_questions, except: :destroy
    resources :villagers do
      post :sync, on: :collection
    end
  end
end
