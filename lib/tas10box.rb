module Tas10
end

module Tas10box
end

require 'mongoid'
require File::expand_path '../../app/models/user', __FILE__
require 'tas10/errors'
require 'tas10/log_entry'
require 'tas10/access_control'
require 'tas10/content_repository'

