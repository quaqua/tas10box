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
    puts @labels.inspect
    respond_with @labels
  end

  # creates a label
  #
  def create
    @doc = Label.new( params[:label] ).with_user( current_user )
    tas10_safe_create( @doc )
    respond_with @doc do |format|
      format.js{ render :template => '/documents/create' }
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
    q.where( :label_ids => [] ) if params[:roots]
    q.where( :name => /#{params[:term]}/i ) unless params[:term].blank?
    q.where( :template => /#{params[:template]}/i ) unless params[:template].blank?
    q
  end

  def get_label_by_id
    Label.where( :id => params[:id] ).first_with_user( current_user )
  end

end