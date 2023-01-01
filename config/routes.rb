Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  #ルートを選択画面に設定する。
  root "auths#show"

  # auths controller
  resource :auths do
    get 'logout'
    get 'mypage'
  end

  # rooms controller
  resources :rooms
end
