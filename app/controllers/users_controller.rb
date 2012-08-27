class UsersController < ApplicationController

  layout "tas10box"

  # log in a user
  #
  def login

    return redirect_to root_path if authenticated?

    unless request.post?
      respond_to do |format|
        format.html { render :status => 401 }
        format.m
      end
      return
    end
    if authenticate(params[:name_or_email], params[:password])
      camefrom = session[:came_from]
      redirect_to ( (camefrom && camefrom != "/login") ? 
        session[:came_from] : 
        dashboard_path )
    end
  end
  
  # logut the user
  #
  def logout
    logout_user
    redirect_to login_path
  end

end
