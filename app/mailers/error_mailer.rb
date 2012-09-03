class ErrorMailer < ActionMailer::Base
  default :from => (Tas10box::defaults[:mail_from] || "no-reply@tastenwerk.com")
 
  def application_error(error,current_user,request)
    @e = error
    @user = current_user
    @request = request
    mail(:to => (Tas10box::defaults[:support_mail] || "support@tastenwerk.com"),
         :subject => "[#{Tas10box::defaults[:site][:name]}] #{error.class.name}")
  end
   
end
