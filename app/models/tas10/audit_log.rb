class Tas10::AuditLog
  include Mongoid::Document

  field :action, type: String
  field :created_at, type: DateTime, default: ->{ Time.now }
  field :additional_message, type: String
  field :document_name, type: String
  field :document_type, type: String
  field :label_name, type: String
  field :group_name, type: String
  field :label_type, type: String
  field :changed_fields, type: Array
  field :user_name, type: String
  field :acl, type: Hash, default: {}

  belongs_to :user, :class_name => "Tas10::User"
  belongs_to :document, :class_name => "Tas10::Document"
  belongs_to :label
  belongs_to :group, :class_name => "Tas10::Group"

  before_create :setup_doc_label_name

  private

  def setup_doc_label_name
    if document
      self.document_type = document.class.name
      self.document_name = document.name
      self.acl = document.acl
    else
      self.acl = {:"#{Tas10::User.everybody_id}" => {:privileges => 'r'} }
    end
    if label
      self.label_type = label.class.name
      self.label_name = label.name
    end
    if user
      self.user_name = user.fullname_or_name
    end
    if group
      self.group_name = group.name
    end
  end

end