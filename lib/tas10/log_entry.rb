require 'mongoid'

class LogEntry
  include Mongoid::Document

  field :at, type: Time
  belongs_to :user, :class_name => "User"
  field :changed_fields, type: Hash

end
