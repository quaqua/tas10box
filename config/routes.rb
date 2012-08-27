Rails.application.routes.draw do

  match "/login" => "Users#login"
  get "/logout" => "Users#logout"
  match '/forgot_password' => "Users#forgot_password"

end
