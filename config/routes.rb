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
      get :known
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
    member do
      get :info
      get :children_for
    end
    resources :comments
    resources :labels
    resources :acl
  end
  resources :tas10_comments, :controller => "Comments"
  resources :comments

  resources :labels do
    member do
      get :children
    end
  end
  resources :acl

end
