class Tas10boxController < ActionController::Base

  setup_tas10box
  protect_from_forgery
  layout 'tas10box'

  before_filter :set_locale

  def set_locale
    return if session[:locale] and !params.has_key?(:locale)
    if params[:locale] && Tas10box.defaults[:locales].include?(params[:locale].downcase)
      I18n.locale = (session[:locale] = params[:locale])
    elsif current_user and current_user.settings["locale"]
      I18n.locale = (session[:locale] = current_user.settings["locale"])
    elsif request.env.has_key?("HTTP_ACCEPT_LANGUAGE") and detected_locale = request.env["HTTP_ACCEPT_LANGUAGE"][0..1] 
      if Tas10box.defaults[:locales].include?(detected_locale.downcase)
        I18n.locale = (session[:locale] = detected_locale)
      else
        session[:locale] = I18n.locale
      end
    else
      session[:locale] = I18n.locale
    end
  end
  
  rescue_from Error404, :with => :render_404
  rescue_from Exception, :with => :render_500 if Rails.env == 'production' && !defined?(JRUBY_VERSION)
  rescue_from ActionView::MissingTemplate do |exception|
    if Rails.env == 'production'
      redirect_to "#{dashboard_path}"
    else
      raise exception
    end
  end
 
 def render_404
    respond_to do |type| 
      type.html { render :template => "errors/error_404", :status => 404, :layout => 'application' } 
      type.all  { render :nothing => true, :status => 404 } 
    end
    true
  end

  def render_500(e)
    ErrorMailer.application_error(e,current_user,request).deliver
    logger.error(e.inspect)
    logger.error(e.backtrace)
    @e = e
    render :template => 'dashboard/500', :status => 500
  end

  private

  def detect_mobile_device
    request.format = :m if mobile? && (request.format.to_s.downcase.include? "html") && (session[:mobile].nil? || session[:mobile] == true)
  end

  def mobile?
    case
    when !params[:_mobile].blank?
      if params[:_mobile] == "true" || params[:_mobile] == "1"
        session[:mobile] = true
      else
        session[:mobile] = false
      end
    when !session[:mobile].blank?
      session[:mobile]
    else
      request.user_agent =~ /phone|ndroid|Mobile|webOS/
    end
  end

end
