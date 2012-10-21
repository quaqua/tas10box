Rails.application.routes.draw do

  #root :to => "Dashboard#index"
  
  get "/dashboard" => "Dashboard#index"
  match "/login" => "Users#login"
  get "/logout" => "Users#logout"
  match '/forgot_password' => "Users#forgot_password"

  resources :preferences

  resources :tas10_users, :controller => "Users"
  resources :users do
    collection do
      get :groups
    end
    member do
      post :picture
      get :picture_of
      get :known
      get :confirm
      post :reset_password_for
      post :add_group_to
      post :remove_group_to
    end
  end
  resources :groups do
    member do
      post :add_user_to
      delete :remove_user_from
    end
  end

  resources :groups

  resources :tas10_groups, :controller => "Groups"

  resources :documents do
    collection do
      match :find
      get :favorite
      match :restore
    end
    member do
      get :info
      get :children_for
      post :sort
      match :restore
    end
    resources :comments
    resources :labels
    resources :acl
  end
  resources :tas10_documents, :controller => "Documents"
  resources :tas10_comments, :controller => "Comments"
  resources :comments

  # labels hierarchical organization
  #
  resources :labels do
    member do
      get :children
    end
  end

  # Access control
  # used to share documents with other users
  resources :acl

  # History (showing activity)
  resources :history

  # QueryScripts
  resources :query_scripts

  # DataFiles file storages
  resources :data_files do
    member do
      get :thumb
    end
  end
  resources :images, :controller => "DataFiles" do
    member do
      get :thumb
    end
  end

end
