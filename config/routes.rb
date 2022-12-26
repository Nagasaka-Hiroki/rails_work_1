Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  # auths controller
  resource :auths do
    get 'logout'
    get 'mypage'
  end
  # rooms controller
  resources :rooms do
    member do
      #発言内容を保存するための設定
      post 'record_chat'
    end
  end
end
