module Tas10
end

require 'mongoid'
require File::expand_path '../../app/models/user', __FILE__
require 'tas10/errors'
require 'tas10/log_entry'
require 'tas10/user_setting'
require 'tas10/user_log_entry'
require 'tas10/access_control'
require 'tas10/document_array'
require 'tas10/labeling'
require 'tas10/content_repository'


module Tas10box

  def defaults( options=nil )
    if options
      @@defaults || @@defaults = options
    else
      @@defaults ||= {}
    end
    @@defaults
  end

  module Rails
    require 'tas10box/rails/engine'
    require 'tas10box/version'
  end

end