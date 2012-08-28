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

  # sends the picture of the user
  # if no picture is set up, a default picture will be used
  # 
  # @param [ String ] size - the size of the desirec picture
  # @example 
  # ?size=50
  #
  def picture_of
    user = get_user_by_id
    filename = File::join Tas10box.defaults[:datastore], "users", user.id.to_s
    size = params[:size] || "50"
    use_filename = "picture_of_#{user.name.gsub(' ','_')}_#{size}x#{size}.png"
    unless File::exists? filename
      filename = File::join( Tas10box::root, "/vendor/assets/images/nopic_#{size}x#{size}.png" )
      use_filename = "default_picture_#{size}x#{size}.png"
    end
    send_file( filename,
              :type => "image/png",
              :filename => use_filename,
              :disposition => 'inline' )

  end
  
  # logut the user
  #
  def logout
    logout_user
    redirect_to login_path
  end

  private

  def get_user_by_id
    Tas10::User.where(:id => params[:id]).first
  end

end
