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
    if @doc.save(:safe => true)
      flash[:notice] = t('document.saved_with_changes', :name => @doc.name, :changes => @doc.changed.join(', '))
    else
      flash[:error] = t('saving_failed', :name => @doc.name, :reason => @doc.errors.messages.inspect)
    end
    respond_with @doc
  end

  def show
    @doc = get_doc_by_id
    render :template => "#{@doc.class.name.underscore.pluralize}/show"
  end

  def edit
    @doc = get_doc_by_id
    redirect_to :controller => @doc.class.name.demodulize.underscore.pluralize, :action => :edit, :id => params[:id]
    #render :template => "#{@doc.class.name.underscore.pluralize}/edit"
  end

  # get the document's info
  def info
    @doc = get_doc_by_id
    respond_with @doc
  end

  def sort
    succeeded = 0
    params[:item].each_with_index do |id,i|
      item = Tas10::Document.where(:id => id).first_with_user( current_user )
      item.versionless do
        if item.update_attributes( :pos => i )
          succeeded += 1
        end
      end
    end
    if succeeded == params[:item].size
      flash[:notice] = t('document.order_saved')
    else
      flash[:error] = t('document.ordering_failed')
    end
    render :template => "documents/update"
  end

  # removes a document
  #
  def destroy
    if @doc = get_doc_by_id
      if @doc.can_delete?
        if @doc.destroy
          flash[:notice] = t('deleted', :name => @doc.name)
        else
          flash[:error] = t('deletion_failed', :name => @doc.name)
        end
      else
        flash[:error] = t('insufficient_rights', :name => @doc.name)
      end
    else
      flash[:error] = t('not_found')
    end
  end

  # find children of this document
  #
  def children_for
    @docs = Tas10::Document
    @docs = @docs.where(:label_ids => Moped::BSON::ObjectId(params[:id])).order_by(:name.asc)
    if params[:page] && params[:limit]
      render :json => get_prepared_json_for_table
    else
      @docs = @docs.all_with_user( current_user )
      render :json => @docs.to_json
    end
  end

  # find any document matching the given query
  #
  def find
    @conditions = Tas10::Document
    rebuild_dynamic_parameters
    get_query
    get_label_ids_query
    get_conditions
    get_class_type
    @docs = @conditions.order_by(:name.asc)
    if params[:page] && params[:limit]
      render :json => get_prepared_json_for_table
    elsif params[:findCombo]
      @docs = @docs.all_with_user( current_user )
      render :json => @docs.to_json
    else
      @docs = @docs.all_with_user( current_user )
      @label_ids = @docs.inject([]){ |arr,doc| arr += doc.label_ids ; arr }
      @query_scripts = QueryScript.all_with_user( current_user )
      @labels = Tas10::Document.in(:id => @label_ids ).all_with_user( current_user )
    end
  end

  private

  def get_prepared_json_for_table
    @count = @docs.size
    @pages = ( @count > params[:limit].to_i ? @count / params[:limit].to_i : 1 )
    @docs = @docs.skip((params[:page].to_i - 1) * params[:limit].to_i).limit( params[:page].to_i * params[:limit].to_i )
    @docs = @docs.all_with_user( current_user )
    { :total => @count, 
      :page => params[:page].to_i, 
      :page => @pages, 
      :limit => params[:limit].to_i, 
      :data => @docs}.to_json
  end

  def get_doc_by_id
    Tas10::Document.where( :id => params[:id] ).first_with_user( current_user )
  end

  def get_query
    @query = ""
    if params[:query] && params[:query].size > 1
      @conditions = @conditions.where(:name => /#{params[:query]}/i)
      @query << params[:query]
    end
  end

  def get_class_type
    if params[:"_type"] && params[:"_type"].size > 1
      @conditions = @conditions.where(:"_type" => params[:"_type"].classify)
      @query << (@query.size > 0 ? "|" : "") << params[:"_type"]
    end
  end

  def get_conditions
    if params[:conditions] && params[:conditions].size > 1
      params[:conditions].split(',').each do |cond|
        if cond.include? '='
          key, value = cond.split('=')
          @query << (@query.size > 0 ? "|" : "") << cond
          value = value.to_i if ['age','zip'].include?(key)
          @conditions = @conditions.where(:"#{key}" => value)
        elsif cond.include? '>'
          key, value = cond.split('>')
          @query << (@query.size > 0 ? "|" : "") << cond
          value = value.to_i if ['age','zip'].include?(key)
          @conditions = @conditions.where(:"#{key}" => { :$gt => value })
        elsif cond.include? '<'
          key, value = cond.split('<')
          @query << (@query.size > 0 ? "|" : "") << cond
          value = value.to_i if ['age','zip'].include?(key)
          @conditions = @conditions.where(:"#{key}" => { :$lt => value })
        end
      end
    end
  end

  def get_label_ids_query
    if params[:label_ids] && params[:label_ids].size > 2
      labels_q = []
      params[:label_ids].split(',').each do |label_id|
        labels_q << { :label_ids => Moped::BSON::ObjectId(label_id) }
      end
      @conditions = @conditions.where({ :"$or" => labels_q })
      @labels = Tas10::Document.in(:id => params[:label_ids].split(',')).all_with_user( current_user )
      @query << (@query.size > 0 ? "|" : "") << @labels.first.name if @labels.size > 0
    end
  end

  def rebuild_dynamic_parameters
    # taken from http://www.igvita.com/2007/07/31/reconstructing-request-uris-in-rails/
    #
    # assuming the route with /.*/ match is present, and points to :source
    @uri = params[:source] || ""

    # omit true Rails query parameters, and append the rest back to the URI
    query_string = params.select {|k,v| not %w[utf8 authenticity_token action controller source].include?(k)}
    unless query_string.empty?
      query_params = query_string.collect {|k,v| "#{k}=#{v}"}
      @uri << "?" << query_params.join("&")
    end
  end

end