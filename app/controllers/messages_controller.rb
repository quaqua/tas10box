class MessagesController < Tas10boxController

  before_filter :authenticate

  def create
    @user = get_user_by_id
    @message = @user.messages.build( params[:tas10_message].merge({:author_id => current_user.id}) )
    if @message.save(:safe => true)
      if @user.is_a?(Tas10::Document)
        Tas10::AuditLog.create!( :user => current_user, :document => @user, :additional_message => @message.content, :action => 'audit.messageed' )
      end
      flash[:notice] = t('messages.created', :user => @message.user.fullname_or_name)
    else
      flash[:error] = t('messages.creation_failed', :user => @message.user.fullname_or_name)
    end
  end

  def destroy
    @user = get_user_by_id
    @message = @user.messages.where(:id => params[:id]).first
    if current_user.id == @message.user_id || current_user.admin?
      if @message.destroy
        Tas10::AuditLog.create!( :user => current_user, :document => @user, :action => 'audit.message_destroyed' )
        flash[:notice] = t('messages.deleted', :user => @message.user.fullname_or_name)
      else
        flash[:error] = t('messages.deletion_failed', :user => @message.user.fullname_or_name)
      end
    else
      flash[:error] = t('insufficient_rights')
    end
  end

  private

  def get_user_by_id
    doc = Tas10::User.where( :id => params[:user_id] ).first
    doc
  end

end