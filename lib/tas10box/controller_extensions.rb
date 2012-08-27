module Tas10box
  module ControllerExtensions
      
      module ClassMethods

        def self.included(model)
          model.helper_method :authenticated?
          model.helper_method :current_user
          model.helper_method :l_time_ago_in_words
          model.helper_method :current_user_or_anybody
          model.helper_method :known_users_and_groups
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

        # returns the current_user object, if authenticated,
        # the anybody object if not
        def current_user_or_anybody
          current_user ? current_user : Tas10::User.anybody
        end
    
        # checks for valid user and updates user's last_request attribute
        def renew_authentication
          #session[:came_from] = request.path_info
          if valid_session?
            return current_user.update(:last_request_at => Time.now, :skip_audit => true)
          end
          false
        end
        
        # tries to sign in given user's email and password
        def authenticate(name=nil,password=nil)
          return true if renew_authentication
          if name.blank? or password.blank?
            session[:came_from] = request.path_info #unless session[:came_from]
            flash[:error] = I18n.t 'login_required'
            flash[:notice] = flash[:notice]
            redirect_to login_path
            return false
          end
          try_authentication(name,password)
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
          puts "AUTH HERE!"
          came_from = session[:came_from]
          reset_session
          @current_user = Tas10::User.first(:name => name)
          @current_user = Tas10::User.first(:email => name) unless @current_user
          @current_user = nil unless @current_user.match_password( password )
          if @current_user
            if @current_user.suspended?
              flash[:error] = I18n.t('user_has_been_suspended')
              return false
            end
            session[:tas10box] = {:user_id => @current_user.id, :group_id => @current_user.group_ids}
            session[:came_from] = came_from
            if @current_user.update_request_log( request )
              I18n.locale = session[:locale] = (@current_user.settings.locale || I18n.locale)
              return true
            end
            return false
          else
            flash[:error] = I18n.t('login_failed')
            return false
          end
        end

        def valid_session?
          return false unless session[:tas10box]
          @current_user = Tas10::User.where(:id => session[:tas10box][:user_id]).first
          return false unless @current_user
          timeout = ( Tas10box::defaults[:session_timeout_minutes].to_i ).minutes.ago
          if @current_user.request_log_entries.last.at && @current_user.request_log_entries.last.at < timeout
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
