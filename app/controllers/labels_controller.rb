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
    else
      create_label
    end
  end

  # show the label
  #
  def show
    respond_with @doc = get_label_by_id
  end

  private

  def get_labelables_query
    q = Tas10::Document
    q = q.where( :label_ids => [] ) if params[:roots]
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
    puts @doc.inspect
    puts "label"
    puts @label.inspect
    @doc.labels.push( @label )
    respond_to do |format|
      format.js{ render :template => "labels/create_label" }
    end
  end

end