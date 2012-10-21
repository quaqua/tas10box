require 'mongoid'

class LogEntry
  include Mongoid::Document

  field :created_at, type: Time, :default => ->{ Time.now }
  belongs_to :user, :class_name => "Tas10::User"
  field :changed_fields, type: Array, :default => []

  embedded_in :tas10_document

end
