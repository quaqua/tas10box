class LabelsController < Tas10boxController

  before_filter :authenticate
  respond_to :json, :xml, :js

  # returns all labelables either with params given or not
  #
  # valid params are:
  #   * roots [ Boolean ] wether only root documents should be looked up or any (useful in combination with :term)
  #   * term [ String ] a search term goes into a regexp
  #   * template [ String ] the template this document is expected to be associated with
  #
  def index
    @labels = get_labelables_query.all_with_user( current_user )
    if params[:term]
      respond_with @labels.map{ |l| {:id => l.id, :name => l.name, :label => l.name} }
    else
      respond_with @labels
    end
  end

  # creates a label
  #
  def create
    if params[:document_id]
      label_document_with_label
      Tas10::AuditLog.create!( :user => current_user, :doc_name => @doc.name, :label_name => @label.name, :doc_type => @doc.class.name, :action => 'audit.labeled' )
    else
      create_label
      Tas10::AuditLog.create!( :user => current_user, :doc_name => @doc.name, :doc_type => @doc.class.name, :action => 'audit.created' )
    end
  end

  # remove a label
  #
  def destroy
    @doc = Tas10::Document.where(:id => params[:document_id]).first_with_user( current_user )
    @label = Tas10::Document.where(:id => params[:id] ).first_with_user( current_user )
    if @doc && @label
      @doc.label_ids.delete( @label.id )
      if @doc.save(:safe => true)
        flash[:notice] = t('labels.removed', :label => @label.name, :name => @doc.name)
      else
        flash[:error] = t('labels.removing_failed', :label => @label.name, :name => @doc.name) + @doc.errors.messages.inspect.to_s
      end
    else
      flash[:error] = t('not_found', :name => 'label or document')
    end
  end

  # show the label
  #
  def show
    respond_with @doc = get_label_by_id
  end

  # get children of this label
  #
  def children
    @labels = get_labelables_query.all_with_user( current_user )
    respond_with @labels
  end

  private

  def get_labelables_query
    q = Tas10::Document
    q = q.where( :label_ids => [] ) if params[:roots]
    q = q.where( :label_ids => Moped::BSON::ObjectId(params[:id]) ) if params[:id]
    q = q.where( :labelable => true ) unless params[:any]
    q = q.where( :name => /#{params[:term]}/i ) unless params[:term].blank?
    q = q.where( :template => /#{params[:template]}/i ) unless params[:template].blank?
    q
  end

  def get_label_by_id
    Label.where( :id => params[:id] ).first_with_user( current_user )
  end

  def create_label
    @doc = Label.new( params[:label] ).with_user( current_user )
    tas10_safe_create( @doc )
    respond_with @doc do |format|
      format.js{ render :template => '/documents/create' }
    end
  end

  def label_document_with_label
    @doc = Tas10::Document.where( :id => params[:document_id] ).first_with_user( current_user )
    @label = Tas10::Document.where( :id => params[:label_id] ).first_with_user( current_user )
    @doc.labels.push( @label )
    respond_to do |format|
      format.js{ render :template => "labels/create_label" }
    end
  end

end