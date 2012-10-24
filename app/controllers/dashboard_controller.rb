class DashboardController < Tas10boxController

  before_filter :authenticate

  def index
    @messages = []
    Tas10::Document.desc(:"comments[].created_at").limit(30).each do |doc|
      @messages += doc.comments
    end
    Tas10::User.desc(:"comments[].created_at").limit(30).each do |user|
      @messages += user.comments
    end
  end

end