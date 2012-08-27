require 'mongoid'

class UserLogEntry
  include Mongoid::Document

  field :at, type: Time
  field :ip
  field :url, type: String

end

class LoginLogEntry < UserLogEntry
end

class RequestLogEntry < UserLogEntry
end
