class UsersController < Tas10boxController

  layout "tas10box"
  before_filter :authenticate, :except => [ :login, :update, :confirm, :forgot_password ]

  # log in a user
  #
  def login

    return redirect_to dashboard_path if authenticated?

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

  def show
    @user = get_user_by_id
  end

  def edit
    @user = get_user_by_id
  end

  # updates user's attributes
  #
  def update
    if renew_authentication
      @user = get_user_by_id
      if @user.id == current_user.id || current_user.admin?
        puts "HEEEE"
        unless params[:tas10_user][:password].blank?
          @user.password = params[:tas10_user][:password]
          @user.password_confirmation = params[:tas10_user][:password_confirmation]
        end
        if current_user.admin?
          @user.admin = ( params[:tas10_user][:admin] == "1" )
        end
        params[:tas10_user].delete(:admin)
        params[:tas10_user].delete(:password)
        tas10_safe_update( @user, params[:tas10_user] )
      else
        flash[:error] = t('insufficient_rights', :name => @user.fullname_or_name)
      end
      render :template => "users/show"
    else
      update_after_confirmation
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
    size = params[:size] || "30"
    filename = File::join( Tas10box::defaults[:datastore], 'userpics', params[:id], "thumb_#{size}x#{size}.png" )
    use_filename = "userpic_#{params[:id]}_#{size}x#{size}.png"
    puts "looking up #{filename}"
    unless File::exists? filename
      filename = File::join( Tas10box::root, "/vendor/assets/images/nopic_#{size}x#{size}.png" )
      use_filename = "default_picture_#{size}x#{size}.png"
    end
    send_file( filename,
              :type => "image/png",
              :filename => use_filename,
              :disposition => 'inline' )
  end

  # upload a new picture
  #
  # [POST]
  #
  # via ajax qq uploader
  def picture
    @user = get_user_by_id
    if params[:qqfile]
      require 'fileutils'
      ext = File::extname params[:qqfile]
      name = File::basename params[:qqfile]
      if @user.save_picture_to_datastore( request.body )
        if @user.id == current_user.id
          Tas10::AuditLog.create!( :user => current_user, :action => 'audit.changed_profile_pic' )
          flash[:notice] = t('user.mypic_uploaded')
        else
          flash[:notice] = t('user.pic_uploaded', :name => @user.fullname_or_name)
        end
      else
        flash[:error] = t('user.pic_upload_failed')
      end
    else
      flash[:error] = 'something terribly went wrong!'
    end
    render :json => { :flash => { :notice => [flash[:notice]], :error => [flash[:error]] } }.to_json
  end

  # returns all known users for this
  # user
  def known
    @known = Tas10::User
    @known = @known.in( :id => (current_user.known_user_ids+[Tas10::User.anybody_id]) ) unless current_user.admin?
    @known = @known.or([ {:name => /#{params[:term]}/i}, {:fullname => /#{params[:term]}/i}, {:email => /#{params[:term]}/i}]) unless params[:term].blank?
    @users_and_groups = @known.all

    @known = Tas10::Group
    @known = @known.in( :id => current_user.group_ids ) unless current_user.admin?
    @known = @known.where(:name =>  /#{params[:term]}/i) unless params[:term].blank?
    @users_and_groups += @known.all

    respond_to do |format|
      format.json{ render :json => @users_and_groups.map{ |u| {:id => u.id, :name => "#{u.fullname_or_name}#{" - #{u.email}" if u.respond_to?(:email)}}", :label => "#{u.fullname_or_name}#{" - #{u.email}" if u.respond_to?(:email)}" } }.to_json }
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

  def update_after_confirmation
    @user = Tas10::User.where(:email => params[:tas10_user][:email], :confirmation_key => params[:tas10_user][:confirmation_key]).first
    if @user
      @user.password = params[:tas10_user][:password]
      @user.password_confirmation = params[:tas10_user][:password_confirmation]
      @user.save( :safe => true )
      if authenticate( params[:tas10_user][:email], params[:tas10_user][:password] )
        redirect_to dashboard_path
        return
      else
        flash[:error] = t('user.saving_failed', :name => @user.fullname_or_name, :reason => ' authentication failed ')
      end
    else
      flash[:error] = t('user.saving_failed', :name => @user.fullname_or_name, :reason => 'not found')
    end
    render :template => "users/confirm"
  end
end
