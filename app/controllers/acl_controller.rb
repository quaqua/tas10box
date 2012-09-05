class AclController < Tas10boxController

  before_filter :authenticate
  
  def create
    @doc = get_doc_by_id
    if @doc.can_share?
      if @user = get_user_by_id || @user = get_group_by_id
        if @doc.share( @user, params[:privileges] ) && @doc.update( :acl => @doc.acl )
          current_user.known_users.push( @user ) unless current_user.known_user_ids.include?(@user.id) && @user.id == Tas10::User.anybody_id
          Tas10::AuditLog.create!( :user => current_user, :document => @doc, :additional_message => @user.fullname_or_name, :action => 'audit.shared' )
          privileges = params[:privileges]
          privileges = 'r' if @user.id == Tas10::User.anybody_id
          flash[:notice] = t('acl.shared', :name => @doc.name, :user => @user.fullname_or_name, :privileges => privileges )
        else
          flash[:error] = t('acl.sharing_failed', :name => @doc.name, :user => @user.fullname_or_name, :reason => @doc.errors.messages.inspect )
        end
      else
        create_user_and_invite
      end
    else
      flash[:error] = t('insufficient_rights', :name => @doc.name )
    end
  end

  def destroy
    @doc = get_doc_by_id
    if @doc.can_share?
      if @user = get_user_by_id
        if @doc.unshare( @user ) && @doc.save( :safe => true )
          Tas10::AuditLog.create!( :user => current_user, :document => @doc, :additional_message => @user.fullname_or_name, :action => 'audit.unshared' )
          flash[:notice] = t('acl.unshared', :name => @doc.name, :user => @user.fullname_or_name )
        else
          flash[:error] = t('acl.usharing_failed', :name => @doc.name, :user => @user.fullname_or_name, :reason => @doc.errors.messages.inspect )
        end
      end
    else
      flash[:error] = t('insufficient_rights', :name => @doc.name )
    end
  end

  private

  def create_user_and_invite
    @user = Tas10::User.new( :email => params[:email], :invited_by => current_user.id )
    if @user.save( :safe => true )
      if @doc.share( @user, params[:privileges] ) && @doc.update( :acl => @doc.acl )
        current_user.known_users.push( @user ) unless current_user.known_user_ids.include?(@user.id) && @user.id == Tas10::User.anybody_id
        @user.known_users.push( current_user )
        Tas10::AuditLog.create!( :user => current_user, :document => @doc, :additional_message => @user.fullname_or_name, :action => 'audit.invited_and_shared' )
        UserMailer.welcome_email(current_user, @user, user_url(@user), @doc, document_url(@doc)).deliver
        flash[:notice] = t('acl.invited_and_shared', :user_name => @user.fullname_or_name, :doc_name => @doc.name, :privileges => params[:privileges])
      else
        flash[:error] = t('acl.invited_but_sharing_failed', :user_name => @user.fullname_or_name, :doc_name => @doc.name, :reason => @doc.errors.messages.inspect )
      end
    else
      flash[:error] = t('user.invitation_failed', :name => @user.fullname_or_name)
    end
  end

  def get_doc_by_id
    @doc = Tas10::Document.where( :id => params[:document_id] ).first_with_user( current_user )
    @doc
  end

  def get_user_by_id
    Tas10::User.where(:id => ( params[:user_id] || params[:id] ) ).first
  end

  def get_group_by_id
    Tas10::Group.where(:id => ( params[:user_id] || params[:id] ) ).first
  end

end