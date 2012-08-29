class DocumentsController < Tas10boxController

  before_filter :authenticate
  respond_to :json, :js, :html, :xml

  # collects all plugin's forms
  # into one form which is controlled
  # by javascripts
  #
  def new

    @docs = {}
    Tas10box.plugins.each do |plugin|
      klass = plugin.name.singularize
      @docs[klass] = klass.classify.constantize.new if plugin.creates
    end

    respond_with @docs do |format|
      format.html{ render :layout => false }
    end

  end

  # get a document only as jason
  #
  def show
    respond_with @doc = get_doc_by_id
  end

  # update the document or only a single attribute
  #
  def update
    @doc = get_doc_by_id
    @doc.attributes = params[:tas10_document]
    @changes = []
    @doc.changes.each_pair do |attr, v|
      @changes << attr
    end
    if @doc.save(:safe => true)
      flash[:notice] = t('document.saved_with_changes', :name => @doc.name, :changes => @changes.join(', '))
    else
      flash[:error] = t('saving_failed', :name => @doc.name, :reason => @doc.errors.messages.inspect)
    end
    respond_with @doc
  end

  # get the document's info
  def info
    @doc = get_doc_by_id
    respond_with @doc
  end

  def destroy
    @doc = get_doc_by_id
    if @doc.destroy
      flash[:notice] = t('document.deleted', :name => @doc.name)
    else
      flash[:error] = t('document.deletion_failed', :name => @doc.name)
    end
  end

  private

  def get_doc_by_id
    Tas10::Document.where( :id => params[:id] ).first_with_user( current_user )
  end

end