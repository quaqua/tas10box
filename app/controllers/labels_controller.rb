class LabelsController < Tas10boxController

  before_filter :authenticate
  respond_to :json, :xml, :js

  def new
    @label = Label.new
  end
  
  # returns all labelables either with params given or not
  #
  # valid params are:
  #   * roots [ Boolean ] wether only root documents should be looked up or any (useful in combination with :term)
  #   * term [ String ] a search term goes into a regexp
  #   * template [ String ] the template this document is expected to be associated with
  #
  def index
    @labels = get_labelables_query.order_by(:name.asc).all_with_user( current_user )
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
      Tas10::AuditLog.create!( :user => current_user, :document => @doc, :label => @label, :action => 'audit.labeled' )
    else
      create_label
    end
  end

  # updates a label
  #
  def update
    @doc = get_label_by_id
    @close_dialog = true
    tas10_safe_update( @doc, params[:label] )
    logger.debug @doc.columns.inspect
    render :template => "documents/update"
  end

  # edit a label
  #
  def edit
    @label = get_label_by_id
  end

  # remove a label
  #
  def destroy
    @doc = Tas10::Document.where(:id => params[:document_id]).first_with_user( current_user )
    @label = Tas10::Document.where(:id => params[:id] ).first_with_user( current_user )
    if @doc && @label
      @doc.label_ids.delete( @label.id )
      if @doc.save(:safe => true)
        Tas10::AuditLog.create!( :user => current_user, :document => @doc, :label => @label, :action => 'audit.label_removed' )
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
    respond_to do |format|
      format.html{ redirect_to "#{dashboard_path}?_type=#{self.class.name.underscore.gsub('_controller','')}&id=#{params[:id]}" }
      format.js do
        @doc = @label = get_label_by_id
        @docs = Tas10::Document.where(:label_ids => Moped::BSON::ObjectId(params[:id]))
        @label_ids = @docs.inject([]){ |arr,doc| arr += doc.label_ids ; arr }
        @labels = Tas10::Document.in(:id => @label_ids ).all_with_user( current_user )
        unless @doc.template.blank?
          render :template => @doc.template
        end
      end
    end
  end

  # get children of this label
  #
  def children
    @labels = get_labelables_query.all_with_user( current_user )
    respond_with @labels
  end

  private

  def get_labelables_query
    q = ( params[:_type] ? params[:_type].classify.constantize : Tas10::Document )
    q = q.where( :label_ids => [] ) if params[:roots]
    q = q.where( :label_ids => Moped::BSON::ObjectId(params[:id]) ) if params[:id]
    q = q.where( :labelable => true ) unless params[:any]
    q = q.where( :name => /#{params[:term]}/i ) unless params[:term].blank?
    unless params[:template].blank?
      if params[:template] == 'empty'
        q = q.all_of( :"$or" => [{ :template => ''}, {:template => nil}] )
      else
        q = q.where( :template => /#{params[:template]}/i )
      end
    end
    q
  end

  def get_label_by_id
    Label.where( :id => params[:id] ).first_with_user( current_user )
  end

  def create_label
    @doc = Label.new( params[:label] ).with_user( current_user )
    tas10_safe_create( @doc )
  end

  def label_document_with_label
    @doc = Tas10::Document.where( :id => params[:document_id] ).first_with_user( current_user )
    @label = Tas10::Document.where( :id => params[:label_id] ).first_with_user( current_user )
    @from = Tas10::Document.where( :id => params[:from_id] ).first_with_user( current_user ) if params[:from_id] && params[:from_id] != '/'
    if @doc.id == @label.id
      flash[:error] = t('labels.cannot_label_with_itself', :name => @doc.name)
    elsif @doc.label_ids.include? @label.id
      flash[:error] = t('labels.already_labeled', :name => @doc.name, :label => @label.name)
    elsif @label.label_ids.include? @doc.id
      flash[:error] = t('labels.circular_labeling_not_allowed', :name => @doc.name, :label => @label.name)
    else
      if @from
        @doc.labels.pull( @from )
        flash[:notice] = t('labels.moved', :name => @doc.name, :from => @from.name, :to => @label.name)
        Tas10::AuditLog.create!( :user => current_user, :document => @doc, :label => @from, :action => 'audit.label_removed' )
      else
        flash[:notice] = t('labels.created', :name => @doc.name, :label => @label.name)
      end
      @doc.labels.push( @label )
    end
    respond_to do |format|
      format.js{ render :template => "labels/create_label" }
    end
  end

end