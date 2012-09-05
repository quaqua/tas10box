class GroupsController < Tas10boxController

  before_filter :authenticate

  def show
    @group = get_group_by_id
  end

  def edit
    if current_user.admin?
      @group = get_group_by_id
    else
      flash[:error] = t('only_admin')
    end
  end

  def update
    if current_user.admin?
      if @group = get_group_by_id
        if @group.update_attributes( :name => params[:tas10_group][:name] )
          flash[:notice] = t('saved', :name => @group.name)
        else
          flash[:error] = t('saving_failed', :name => @group.name)
        end
      else
        flash[:error] = t('not_found')
      end
    else
      flash[:error] = t('only_admin')
    end
    render :template => "groups/show"
  end

  def add_user_to
    if current_user.admin?
      @group = get_group_by_id
      @user = get_user_by_user_id
      @user.groups.push( @group ) unless @user.group_ids.include?( @group.id )
      flash[:notice] = t('user.added_to_group', :name => @user.fullname_or_name, :group => @group.name)
    else
      flash[:error] = t('only_admin')
    end
  end

  def remove_user_from
    if current_user.admin?
      @group = get_group_by_id
      @user = get_user_by_user_id
      @user.groups.delete( @group )
      flash[:notice] = t('user.removed_from_group', :name => @user.fullname_or_name, :group => @group.name)
    else
      flash[:error] = t('only_admin')
    end
  end

  private

  def get_group_by_id
    Tas10::Group.where(:id => params[:id]).first
  end

  def get_user_by_user_id
    Tas10::User.where(:id => params[:user_id]).first
  end

end