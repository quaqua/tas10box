class AclController < Tas10boxController

  before_filter :authenticate
  
  def create
    @docs = []
    if params[:doc_ids].blank? || params[:doc_ids].size == 0
      @docs << get_doc_by_id
    else
      params[:doc_ids].split(',').each{ |doc_id| @docs << get_doc_by_id( doc_id ) }
    end
    @user = get_user_by_id || @user = get_group_by_id
    create_user_and_invite unless @user
    unless current_user.known_user_ids.include?(@user.id) && @user.id == Tas10::User.anybody_id
      current_user.known_users.push( @user )
    end
    succeeded = 0
    errors = {}
    @docs.each do |doc|
      if doc.can_share?
        doc.versionless do
          if doc.share( @user, params[:privileges] ) && doc.update_attribute( :acl, doc.acl )
            privileges = params[:privileges]
            privileges = 'r' if @user.id == Tas10::User.anybody_id
            succeeded += 1
          end
        end
      else
        errors[doc.id] = t('insufficient_rights', :name => @doc.name )
      end
    end
    if succeeded == @docs.size
      doc_names = @docs.map{|d| d.name }.join(', ')
      Tas10::AuditLog.create!( :user => current_user, :document_name => doc_names, :additional_message => @user.fullname_or_name, :action => 'audit.shared' )
      flash[:notice] = t('acl.shared', :name => doc_names, :user => @user.fullname_or_name, :privileges => params[:privileges] )
    else
      flash[:error] = t('acl.sharing_failed', :name => @doc.name, :user => @user.fullname_or_name, :reason => @doc.errors.messages.inspect )
    end
  end

  def destroy
    @doc = get_doc_by_id
    if @doc.can_share?
      if @user = get_user_by_id
        @doc.versionless do
          if @doc.unshare( @user ) && @doc.save( :safe => true )
            Tas10::AuditLog.create!( :user => current_user, :document => @doc, :additional_message => @user.fullname_or_name, :action => 'audit.unshared' )
            flash[:notice] = t('acl.unshared', :name => @doc.name, :user => @user.fullname_or_name )
          else
            flash[:error] = t('acl.usharing_failed', :name => @doc.name, :user => @user.fullname_or_name, :reason => @doc.errors.messages.inspect )
          end
        end
      end
    else
      flash[:error] = t('insufficient_rights', :name => @doc.name )
    end
  end

  private

  def get_doc_by_id( doc_id=params[:document_id] )
    @doc = Tas10::Document.where( :id => doc_id ).first_with_user( current_user )
  end

  def get_user_by_id
    Tas10::User.where(:id => ( params[:user_id] || params[:id] ) ).first
  end

  def get_group_by_id
    Tas10::Group.where(:id => ( params[:user_id] || params[:id] ) ).first
  end

end