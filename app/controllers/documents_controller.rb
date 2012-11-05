class DocumentsController < Tas10boxController

  before_filter :authenticate
  respond_to :json, :js, :html, :xml

  # collects all plugin's forms
  # into one form which is controlled
  # by javascripts
  #
  def new
    respond_to do |format|
      format.html{ render :layout => false }
      format.js
    end
  end

  # get a document only as jason
  #
  def show
    respond_to do |format|
      format.json{ render :json => get_doc_by_id.to_json }
      format.html{ redirect_to "#{dashboard_path}?_type=#{self.class.name.underscore.gsub('_controller','')}&id=#{params[:id]}" }
    end
  end

  def favorite
    @docs = Tas10::Document.where(:starred => true).asc(:name).all_with_user( current_user )
    respond_to do |format|
      format.json{ render :json => @docs.to_json }
    end
  end

  # update the document or only a single attribute
  #
  def update
    @doc = get_doc_by_id
    @doc.attributes = params[:tas10_document]
    @doc.skip_audit
    @doc.versionless do
      if @doc.update_attributes( params[:tas10_document] )
        if params[:tas10_document].size == 1 && params[:tas10_document][:starred]
          if @doc.starred?
            Tas10::AuditLog.create!( :user => current_user, :document => @doc, :action => 'audit.marked_favorite' )
            flash[:notice] = t('dmarked_favorite', :name => @doc.name)
          else
            Tas10::AuditLog.create!( :user => current_user, :document => @doc, :action => 'audit.unmarked_favorite' )
            flash[:notice] = t('unmarked_favorite', :name => @doc.name)
          end
        else
          @doc.skip_audit = nil
          @doc.update_log
          flash[:notice] = t('document.saved_with_changes', :name => @doc.name, :changes => @doc.changed.join(', '))
        end
      else
        flash[:error] = t('saving_failed', :name => @doc.name, :reason => @doc.errors.messages.inspect)
      end
    end
    respond_to do |format|
      format.js{ @doc }
      format.json{ render :json => @doc.to_json }
    end
  end

  def show
    @doc = get_doc_by_id
    redirect_to :controller => @doc.class.name.demodulize.underscore.pluralize, :action => :show, :id => params[:id]
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

  def publish
    if @doc = get_doc_by_id
      @doc.can_read?( anybody ) ? @doc.unshare( anybody ) : @doc.share( anybody, 'r' )
      if @doc.update( :acl => @doc.acl )
        if @doc.published?
          flash[:notice] = t('published', :name => @doc.name)
        else
          flash[:notice] = t('unpublished', :name => @doc.name)
        end
      else
        flash[:error] = t('publishing_failed', :name => @doc.name, :reason => @doc.errors.messages.inspect.to_s)
      end
    end
  end


  def sort
    succeeded = 0
    if params[:item]
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
    else
      flash[:error] = "Keine Elemente erhalten. Keine Sortierung gespeichert!"
    end
    render :template => "documents/update"
  end

  # removes a document
  #
  def destroy
    if @doc = get_doc_by_id
      if @doc.can_delete?
        if @doc.destroy
          flash[:notice] = "#{t('deleted', :name => @doc.name)} <a href=\"/documents/#{@doc.id}/restore\" class=\"undo\" data-remote=\"true\" data-method=\"post\">#{t('undo')}</a>"
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

  def restore
    params[:keep_open] = true
    if params[:id]
      if @doc = Tas10::Document.deleted.where(:id => params[:id]).first_with_user( current_user )
        puts @doc.inspect
        if @doc.can_delete?
          if @doc.restore
            flash[:notice] = t('restored', :name => @doc.name)
          else
            flash[:error] = t('restoring_failed', :name => @doc.name)
          end
        else
          flash[:error] = t('insufficient_rights', :name => @doc.name)
        end
      else
        flash[:error] = t('not_found')
      end
    else
      restored = []
      params[:ids].split(',').each do |id|
        if @doc = Tas10::Document.deleted.where(:id => params[:id]).first_with_user( current_user )
          if @doc.restore
            restored << @doc.name
          end
        end
      end
      flash[:notice] = t('restored', :name => restored.join(', '))
    end
  end

  # find children of this document
  #
  def children_for
    if params[:id].blank?
      render :json => {}.to_json
      return
    end
    @docs = Tas10::Document
    @docs = @docs.where(:label_ids => Moped::BSON::ObjectId(params[:id]))
    @docs = @docs.where(:_type => params[:_type]) unless params[:_type].blank?
    if params[:order_by] && params[:order_by] == "position"
      @docs = @docs.asc :pos
    else
      @docs = @docs.order_by(:name.asc)
    end
    if params[:_search]
      render :json => get_prepared_json_for_table
    else
      @docs = @docs.all_with_user( current_user )
      render :json => @docs.to_json
    end
  end

  # find any document matching the given query
  #
  def find
    @conditions = Tas10::Document.all_of
    rebuild_dynamic_parameters
    get_query
    get_label_ids_query
    get_conditions
    get_class_type
    @docs = @conditions.order_by(:name.asc)
    if params[:_search]
      render :json => get_prepared_json_for_table
    elsif params[:findCombo]
      @docs = @docs.limit( 30 )
      @docs = @docs.all_with_user( current_user )
      render :json => @docs.to_json
    else
      @docs = @docs.limit( 100 )
      @docs = @docs.all_with_user( current_user )
      respond_to do |format|
        format.json{ render :json => @docs.as_json.to_json }
        format.js do
          @label_ids = @docs.inject([]){ |arr,doc| arr += doc.label_ids ; arr }
          @query_scripts = QueryScript.all_with_user( current_user )
          @labels = Tas10::Document.in(:id => @label_ids ).all_with_user( current_user )
          @docs = @docs.map{ |d| d.as_json }
        end
      end
    end
  end

  private

  def get_prepared_json_for_table
    @docs = @docs.skip((params[:page].to_i - 1) * params[:rows].to_i).limit( params[:page].to_i * params[:rows].to_i )
    records = @docs.size
    price_total = 0
    tickets_total = 0
    total = ( records > params[:rows].to_i ? records / params[:rows].to_i : 1 )
    @docs = @docs.all_with_user(current_user).as_json
    @docs.sort_by!{ |b| b[:"#{params[:sidx]}"] }
    @docs.reverse! if params[:sord] == "desc"
    { :total => @count, 
      :page => params[:page].to_i, 
      :records => records,
      :total => total,
      :rows => @docs }.to_json
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
    if params[:types] && params[:types].size > 1
      types = []
      params[:types].split(',').each do |t| 
        if t == 'events'
          types << 'WebpageEvent'
          types << 'CalendarEvent'
        else
          types << t.singularize.classify
        end
      end
      @conditions = @conditions.in(:_type => types)
    end
  end

  def get_conditions
    replacements = {"kontostand" => "balance", "email" => "email_addresses", "phone" => "phone_numbers", "street" => "street_addresses", "alter" => "age"}
    exceptions = ['age','zip','balance','amount']
    if params[:conditions] && params[:conditions].size > 1
      params[:conditions].split(',').each do |cond|
        if cond.include? '='
          key, value = cond.split('=')
          replacements.each_pair{ |replk,replv| key = replv if key.downcase == replk }
          value = (value == 'true') if value.match(/true|false/)
          @query << (@query.size > 0 ? "|" : "") << cond
          value = value.to_i if exceptions.include?(key)
          @conditions = @conditions.where(:"#{key}" => value)
        elsif cond.include? '>'
          key, value = cond.split('>')
          replacements.each_pair{ |replk,replv| key = replv if key.downcase == replk }
          @query << (@query.size > 0 ? "|" : "") << cond
          value = value.to_i if exceptions.include?(key)
          @conditions = @conditions.where(:"#{key}" => { :$gt => value })
        elsif cond.include? '<'
          key, value = cond.split('<')
          replacements.each_pair{ |replk,replv| key = replv if key.downcase == replk }
          @query << (@query.size > 0 ? "|" : "") << cond
          value = value.to_i if exceptions.include?(key)
          @conditions = @conditions.where(:"#{key}" => { :$lt => value })
        elsif cond.include? '~'
          key, value = cond.split('~')
          replacements.each_pair{ |replk,replv| key = replv if key.downcase == replk }
          @query << (@query.size > 0 ? "|" : "") << cond
          @conditions = @conditions.where(:"#{key}" => /#{value}/i )
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
      @conditions = @conditions.all_of({ :"$or" => labels_q })
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