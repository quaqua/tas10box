class DashboardController < Tas10boxController

  before_filter :authenticate

  def index
    @messages = []
    Tas10::Document.desc(:"comments[].created_at").limit(30).each do |doc|
      @messages += doc.comments
    end
    Tas10::User.desc(:"comments[].created_at").limit(30).each do |user|
      @messages += user.messages
    end
    @messages.sort!{ |a,b| a.created_at <=> b.created_at }.reverse!
  end

end