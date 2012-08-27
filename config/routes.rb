Rails.application.routes.draw do

  root :to => "Dashboard#index"
  
  match "/login" => "Users#login"
  get "/logout" => "Users#logout"
  match '/forgot_password' => "Users#forgot_password"

end
