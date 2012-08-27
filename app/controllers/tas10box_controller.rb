class Tas10boxController < ActionController::Base

  protect_from_forgery
  tas10box_defaults
  layout 'tastenbox'

  before_filter :renew_authentication,
                :set_locale,
                :detect_mobile_device

  def set_locale
    return if session[:locale] and !params.has_key?(:locale)
    known = Tastenbox::env.get(:known_locales) || ["de","en"]
    if params[:locale] && known.include?(params[:locale].downcase)
      I18n.locale = (session[:locale] = params[:locale])
    elsif current_user and current_user.default_locale
      I18n.locale = (session[:locale] = current_user.default_locale)
    elsif request.env.has_key?("HTTP_ACCEPT_LANGUAGE") and detected_locale = request.env["HTTP_ACCEPT_LANGUAGE"][0..1] 
      if known.include?(detected_locale.downcase)
        I18n.locale = (session[:locale] = detected_locale)
      else
        session[:locale] = I18n.locale
      end
    else
      session[:locale] = I18n.locale
    end
  end
  
  rescue_from Exception, :with => :render_500 if Rails.env == 'production' && !defined?(JRUBY_VERSION)
 
  def render_500(e)
    ErrorMailer.application_error(e,current_user,request).deliver
    logger.error(e.inspect)
    logger.error(e.backtrace)
    @e = e
    render :template => 'dashboard/500', :status => 500
  end
  
  def render_404(e)
    render :template => 'dashboard/404', :status => 404
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
