Rails.application.routes.draw do
  get "terms",   to: "static_pages#terms"
  get "privacy", to: "static_pages#privacy"

  # お問い合わせ
  resources :contacts, only: [ :new, :create ], path: "contact" do
    collection do
      get :thanks
    end
  end

  # アプリ設定
  resource :app_settings, only: [ :show ]

  # 管理者
  namespace :admin do
    resources :advice_suggestions, only: %i[index show destroy] do
      member do
        get  :new_advice
        post :create_advice
        patch :create_advice
        patch :reject
        patch :restore
        delete :delete_forever
      end
    end

    resources :advices, only: %i[index show edit update destroy]
  end

  # ユーザー投稿
  resources :advice_suggestions, only: [ :index, :new, :create, :show ]
  resources :advices, only: [ :show ]
  resources :favorites, only: [ :index, :create, :destroy ]
  resources :rankings, only: [ :index ]

  # 🔧 ユーザー設定（ハブ）
  get "settings", to: "settings#index"

  # 👤 プロフィール（単数）
  resource :profile, only: %i[show edit update]

  #  Devise分離（メール / パスワード / 退会）
  namespace :users do
    get "withdrawals/show"
    get "passwords/edit"
    get "emails/edit"
    get "emails/update"
    resource :email,      only: [ :edit, :update ]
    resource :password,   only: [ :edit, :update ]
    resource :withdrawal, only: [ :show, :destroy ]
  end

  # 認証
  devise_for :users

  # メイン
  resources :owls, only: [ :index, :show ]

  get "up" => "rails/health#show", as: :rails_health_check
  root "owls#index"
end
