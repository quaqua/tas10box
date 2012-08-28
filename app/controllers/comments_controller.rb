class CommentsController < Tas10boxController

  before_filter :authenticate

  def create
    @doc = get_doc_by_id
    @comment = @doc.comments.build( params[:tas10_comment].merge({:user => current_user}) )
    if @comment.save(:safe => true)
      flash[:notice] = t('comments.created', :name => @doc.name)
    else
      flash[:error] = t('comments.creation_failed', :name => @doc.name)
    end
  end

  def destroy
    @comment = Comment.where(:id => params[:id]).first
    if current_user.id == @comment.user_id || current_user.admin?
      if @comment.destroy
        flash[:notice] = t('comments.deleted', :name => @comment.name)
      else
        flash[:error] = t('comments.deletion_failed', :name => @comment.name)
      end
    else
      flash[:error] = t('insufficient_rights', :doc => @comment.name)
    end
  end

  private

  def get_doc_by_id
    Tas10::Document.where( :id => params[:document_id] ).first_with_user( current_user )
  end

end