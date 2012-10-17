class QueryScriptsController < Tas10boxController

  before_filter :authenticate

  respond_to :json
  
  def index
    @query_scripts = QueryScript
    @query_scripts = @query_scripts.where(:"doc_type" => params[:doc_type]) if params[:doc_type]
    #@query_scripts = @query_scripts.ne(:query => "") if params[:query] && params[:query] == "true"
    @query_scripts = @query_scripts.all_with_user( current_user )
    render :json => @query_scripts.to_json
  end

  def new
    @query_script = QueryScript.new
    @query_script.query = params[:query] unless params[:query].blank?
  end

  def edit
    @query_script = get_query_script_by_id
  end

  def update
    @query_script = get_query_script_by_id
    tas10_safe_update( @query_script, params[:query_script] )
  end

  def create
    @query_script = @doc = QueryScript.new( params[:query_script] ).with_user( current_user )
    tas10_safe_create( @query_script )
  end

  def show
    @query_script = @doc = QueryScript.where(:id => params[:id]).first_with_user( current_user )
  end

  private

  def get_query_script_by_id
    QueryScript.where(:id => params[:id]).first_with_user( current_user )
  end

end