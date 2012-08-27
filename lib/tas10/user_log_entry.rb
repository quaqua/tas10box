require 'mongoid'

class UserLogEntry
  include Mongoid::Document

  field :at, type: Time
  field :ip, type: String
  field :url, type: String
  field :login, type: Boolean, :default => false

  embedded_in :user, :class_name => "Tas10::User"
end
