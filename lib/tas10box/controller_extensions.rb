module Tas10box
  module ControllerExtensions
      
      module ClassMethods

        def setup_tas10box
          helper_method :authenticated?
          helper_method :current_user
          helper_method :anybody
          helper_method :current_user_or_anybody
          helper_method :l_time_ago_in_words
          helper_method :current_user_or_anybody
          helper_method :known_users_and_groups
        end
      
      end
      
      module InstanceMethods

        include ActionView::Helpers::DateHelper
  
        # check if user is authenticated
        def authenticated?
          valid_session?
        end
        
        def admin_required
          redirect_to dashboard_path unless current_user.is_admin?
        end
    
        def editor_required
          redirect_to dashboard_path unless current_user.is_editor?
        end
    
        # returns current session holding user
        def current_user
          @current_user
        end

        def anybody
          Tas10::User.anybody
        end

        # returns the current_user object, if authenticated,
        # the anybody object if not
        def current_user_or_anybody
          current_user ? current_user : Tas10::User.anybody
        end
    
        # checks for valid user and updates user's last_request attribute
        def renew_authentication( skip_update=nil )
          #session[:came_from] = request.path_info
          if valid_session?
            return true if skip_update
            return current_user.update_request_log( request.env['REMOTE_ADDR'], request.env['REQUEST_PATH'] )
          else
            flash[:error] = I18n.t 'login.session_expired', :limit => Tas10box.defaults[:session_timeout]
          end
          false
        end
        
        # tries to sign in given user's email and password
        def authenticate(name=nil,password=nil)
          return true if renew_authentication
          if name.blank? or password.blank?
            session[:came_from] = request.path_info #unless session[:came_from]
            flash[:error] = I18n.t 'login.required' if flash[:error].blank?
            flash[:notice] = flash[:notice]
            redirect_to login_path
            return false
          end
          try_authentication(name,password)
        end


        def create_user_and_invite
          @user = Tas10::User.new( :email => params[:email], :invited_by => current_user.id )
          if @user.save( :safe => true )
            current_user.known_users.push( @user ) unless current_user.known_user_ids.include?(@user.id) && @user.id == Tas10::User.anybody_id
            @user.known_users.push( current_user )
            if @doc
              if @doc.share( @user, params[:privileges] ) && @doc.update( :acl => @doc.acl )
                Tas10::AuditLog.create!( :user => current_user, :document => @doc, :additional_message => @user.fullname_or_name, :action => 'audit.invited_and_shared' )
                UserMailer.welcome_email(current_user, @user, user_url(@user), @doc, document_url(@doc)).deliver
                flash[:notice] = t('acl.invited_and_shared', :user_name => @user.fullname_or_name, :doc_name => @doc.name, :privileges => params[:privileges])
              else
                flash[:error] = t('acl.invited_but_sharing_failed', :user_name => @user.fullname_or_name, :doc_name => @doc.name, :reason => @doc.errors.messages.inspect )
              end
            else
              Tas10::AuditLog.create!( :user => current_user, :group => @group, :additional_message => @user.fullname_or_name, :action => 'audit.invited_to_group' )
              flash[:notice] = t('user.added_to_group_and_invited', :name => @user.fullname_or_name, :group => @group.name)
              UserMailer.welcome_email(current_user, @user, user_url(@user), nil, nil).deliver
            end
          else
            flash[:error] = t('user.invitation_failed', :name => @user.fullname_or_name)
          end
        end

        # safefully creates the passed document and
        # creates according flash messages
        #
        # @param [ Tas10::Document ] doc
        #
        def tas10_safe_create( doc )
          if doc.save( :safe => true )
            flash[:notice] = t( 'created', :name => doc.name )
          else
            flash[:error] = t( 'creation_failed', :name => ( doc.name ? doc.name : '' ), :reason => doc.errors.messages.inspect.to_s )
          end
        end

        # get a prepared json
        # for given @docs array
        # usefull for tas10table responses
        def get_prepared_json_for_table
          @count = @docs.size
          @pages = ( @count > params[:limit].to_i ? @count / params[:limit].to_i : 1 )
          @docs = @docs.skip((params[:page].to_i - 1) * params[:limit].to_i).limit( params[:page].to_i * params[:limit].to_i )
          @docs = @docs.all_with_user( current_user )
          { :total => @count, 
            :page => params[:page].to_i, 
            :pages => @pages, 
            :limit => params[:limit].to_i, 
            :data => @docs}.to_json
        end

        def tas10_safe_update( doc, attrs )
          if doc.with(:safe => true).update_attributes( attrs )
            flash[:notice] = t( 'saved', :name => doc.name )
          else
            flash[:error] = t( 'saving_failed', :name => ( doc.name ? doc.name : '' ), :reason => doc.errors.messages.inspect.to_s )
          end
        end

        # HTTP Authentication. Can be used, if #authenticate is bypassed and
        # http authentication desired
        def basic_auth
          authenticate_or_request_with_http_basic do |email, password|
            return true if try_authentication(email,password)
          end
          false
        end
        
        # nilifies session cookies and logs out user
        def logout_user
          reset_session
          true
        end
        
        def l_time_ago_in_words(time,future=false)
          locale = session[:locale] || I18n.locale
          res = time_ago_in_words(time)
          case locale.downcase.to_sym
            when :de
              if future
                res = "#{res}n" if res[0..1].to_i > 1
                "#{I18n.t('in')} #{res}"
              else
                "#{I18n.t('ago')} #{res.sub('Tage','Tagen')}"
              end
            else
              if future
                "#{I18n.t('in')} #{res}"
              else
                "#{res} #{I18n.t('ago')}"
              end
            end
        end

        def try_authentication(name,password)
          came_from = session[:came_from]
          reset_session
          @current_user = Tas10::User.where(:name => name).first
          @current_user = Tas10::User.where(:email => name).first unless @current_user
          @current_user = nil if @current_user && !@current_user.match_password( password )
          if @current_user
            if @current_user.suspended?
              flash[:error] = I18n.t('user_has_been_suspended')
              return false
            end
            session[:tas10box] = {:user_id => @current_user.id, :group_id => @current_user.group_ids}
            session[:came_from] = came_from
            if @current_user.update_login_log( request.env['REMOTE_ADDR'], request.env['REQUEST_PATH'] )
              I18n.locale = session[:locale] = (@current_user.settings["locale"] || I18n.locale)
              return true
            end
            return false
          else
            flash[:error] = I18n.t('login.failed')
            return false
          end
        end

        def valid_session?
          return false unless session[:tas10box]
          @current_user = Tas10::User.where(:id => session[:tas10box][:user_id]).first
          return false unless @current_user
          timeout = ( Tas10box::defaults[:session_timeout].to_i ).minutes.ago
          if @current_user.user_log_entries.last.created_at && @current_user.user_log_entries.last.created_at < timeout
            came_from = session[:came_from]
            reset_session
            session[:came_from] = came_from
            flash[:error] = t('session_expired')
            return false
          end
          return true
        end

      end

  end
end
