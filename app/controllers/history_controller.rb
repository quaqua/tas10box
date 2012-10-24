class HistoryController < Tas10boxController

  respond_to :json

  def index
    renew_authentication( :skip_update )
    logs = Tas10::AuditLog
    logs = logs.where(:created_at.gt => (Time.parse(params[:latest]) + 60.seconds)) if params[:latest]
    logs = logs.where(:created_at.gte => "2012-08-31T18:00:00") unless params[:latest]

    q = [{ :"acl.#{current_user.id}.privileges" => /r\w*/ },
         { :"acl.#{Tas10::User.everybody_id}.privileges" => /r\w*/ }]
    current_user.group_ids.each do |group_id|
      q.push({:"acl.#{group_id.to_s}.privileges" => /r\w*/})
    end
    logs = logs.where( "$or" => q )
    logs = logs.order_by(:created_at => :desc).limit(30)
    history = logs.inject(Array.new){ |arr,l| arr << prepare_entry( l ) unless l.user_id.nil? ; arr }
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
      :user_url => (l.user_id ? user_path(l.user_id) : nil),
      :user_name => l.user.fullname_or_name,
      :user_id => l.user_id,
      :message => process_message( l )
    }
  end

  def process_message( l )
    name = ( l.document_id ? 
          "<a href='#{document_path(l.document_id)}' data-remote='true'>#{l.document_name}</a>" :
          ( l.document_name ? l.document_name : nil ) )
    msg = (l.additional_message ? l.additional_message : nil)
    user = (l.user_name ?
          "<a href='#{user_path(l.user_id)}' data-remote='true'>#{l.user_name}</a>" : 
          nil)
    label = (l.label_name ? 
          "<a href='#{document_path(l.label_id)}' data-remote='true'>#{l.label_name}</a>" : 
          nil)
    group = (l.group_name && l.group_id ? 
          "<a href='#{group_path(l.group_id)}' data-remote='true'>#{l.group_name}</a>" : 
          nil)
    m = t( l.action, 
        :name => name,
        :message => msg,
        :user => user,
        :label => label,
        :group => group
        )
    if l.action == 'audit.deleted'
      m += " <a href=\"/documents/#{l.id}/restore\" class=\"undo\" data-remote=\"true\" data-method=\"post\">#{t('undo')}</a>"
    end
    m
  end

end