Rails.application.routes.draw do
  # RESTfulなルーティング
  resources :owls, only: [:index, :show]

  get "up" => "rails/health#show", as: :rails_health_check

  # ルートページをふくちゃんの紹介ページに設定
  root "owls#index"
end
