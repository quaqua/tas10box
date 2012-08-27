Rails.application.routes.draw do

  root :to => "Dashboard#index"
  
  get "/dashboard" => "Dashboard#index"
  match "/login" => "Users#login"
  get "/logout" => "Users#logout"
  match '/forgot_password' => "Users#forgot_password"

  resources :tas10_users, :controller => "Users"
  resources :users do
    collection do
      get :groups
    end
    member do
      get :picture_of
      get :confirm
      post :reset_password_for
      post :add_group_to
      post :remove_group_to
    end
  end

  resources :documents do
    collection do
      get :find
    end
  end

end
