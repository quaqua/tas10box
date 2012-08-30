class UserMailer < ActionMailer::Base
  default :from => Tas10box::defaults[:mail_system][:sender]
 
  def welcome_email( inviter, user, url, doc, doc_url )
    @user = user
    @inviter = inviter
    @url  = url
    @doc_url = doc_url
    @doc = doc
    mail(:to => user.email,
         :subject => "[#{Tas10box::defaults[:site][:name]}] #{I18n.t('mailer.welcome', :platform => "#{Tas10box::defaults[:site][:name]}'s tas10box")}")
  end
 
  def forgot_password_email(user,url)
    @user = user
    @url  = url
    mail(:to => user.email,
         :subject => "[#{Tas10box::defaults[:site][:name]}] #{I18n.t('mailer.forgot_password_request')}")
  end
  
end
