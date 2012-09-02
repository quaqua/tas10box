class HistoryController < Tas10boxController

  respond_to :json

  def index
    renew_authentication( :skip_update )
    logs = Tas10::AuditLog
    logs = logs.where(:created_at.gt => (Time.parse(params[:latest]) + 60.seconds)) if params[:latest]
    logs = logs.where(:created_at.gte => "2012-08-31T18:00:00") unless params[:latest]
    logs = logs.order_by(:created_at => :desc).limit(30)
    history = logs.map{ |l| prepare_entry( l ) }
    respond_with history
  end

  private

  def prepare_entry( l )
    { :id => l.id,
      :label_type => l.label_type,
      :user_name => l.user_name,
      :created_at => l.created_at,
      :ago => l_time_ago_in_words( l.created_at ),
      :document_url => l.document_id && document_path(l.document_id),
      :document_type => l.document_type,
      :label_url => l.label_id && document_path(l.label_id),
      :changed_fields => l.changed_fields,
      :user_url => user_path(l.user_id),
      :user_id => l.user_id,
      :message => t( l.action, 
        :name => ( l.document_id ? 
          "<a href='#{document_path(l.document_id)}' data-remote='true'>#{l.document_name}</a>" :
          nil ),
        :message => (l.additional_message ? l.additional_message : nil),
        :label => (l.label_name ? 
          "<a href='#{document_path(l.label_id)}' data-remote='true'>#{l.label_name}</a>" : 
          nil) 
        )
    }
  end

end