Rails.application.routes.draw do
  namespace :admin do
    resources :advice_suggestions, only: [ :index ] do
      member do
        patch :approve
        patch :reject
      end
    end
  end

  resources :advice_suggestions, only: [ :index, :new, :create ]
  get "settings", to: "settings#index"
  devise_for :users
  # RESTfulなルーティング
  resources :owls, only: [ :index, :show ]

  get "up" => "rails/health#show", as: :rails_health_check

  # ルートページをふくちゃんの紹介ページに設定
  root "owls#index"
end
