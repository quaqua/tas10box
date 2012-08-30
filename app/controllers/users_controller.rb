class UsersController < Tas10boxController

  layout "tas10box"
  before_filter :authenticate, :except => [ :login, :update, :confirm, :forgot_password ]

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

  # updates user's attributes
  #
  def update
    if current_user
      @user = get_user_by_id
    else
      @user = Tas10::User.where(:email => params[:tas10_user][:email], :confirmation_key => params[:tas10_user][:confirmation_key]).first
      if @user && @user.password = params[:tas10_user][:password] && @user.save( :safe => true )
        if authenticate( params[:tas10_user][:email], params[:tas10_user][:password] )
          redirect_to dashboard_path
        else
          flash[:error] = t('user.saving_failed', :reason => ' authentication failed ')
        end
      else
        flash[:error] = t('user.saving_failed', :reason => 'not found')
      end
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

  # returns all known users for this
  # user
  def known
    @known = Tas10::User.in( :id => current_user.known_user_ids ).all
    respond_to do |format|
      format.json{ render :json => @known.map{ |u| {:id => u.id, :name => u.fullname_or_name, :label => u.fullname_or_name } }.to_json }
    end
  end

  # confirm an invitation
  #
  def confirm
    flash[:notice] = t('welcome_on_tas10box', :name => Tas10box::defaults[:site][:name])
    @user = Tas10::User.where(:email => params[:email], :confirmation_key => params[:key]).first
    puts @user.inspect
    not_found unless params[:key] and @user
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
