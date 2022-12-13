Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  # auth controller
  resource :auths do
    #get 'login'
    get 'logout'
    get 'mypage'
  end
end
