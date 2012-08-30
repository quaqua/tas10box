class Tas10::AuditLog
  include Mongoid::Document

  field :action, type: String
  field :created_at, type: DateTime, default: ->{ Time.now }
  field :doc_name, type: String
  field :doc_type, type: String
  field :changed_fields, type: Array

  belongs_to :document, :class_name => "Tas10::Document"
  belongs_to :user, :class_name => "Tas10::User"

end