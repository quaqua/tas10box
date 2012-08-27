module Tas10
end

require 'mongoid'
require File::expand_path '../../app/models/tas10/user', __FILE__
require 'tas10/errors'
require 'tas10/log_entry'
require 'tas10/user_setting'
require 'tas10/user_log_entry'
require 'tas10/access_control'
require 'tas10/document_array'
require 'tas10/labeling'
require 'tas10/content_repository'
require 'tas10box/plugin'

module Tas10box

  def self.plugins
    @plugins ||= []
  end

  def self.register_plugin( plugin )
    @plugins ||= []
    @plugins << plugin
  end

  def self.defaults( options=nil )
    @defaults ||= { :locales => ["de", "en"], 
      :site => { :name => 'My Company' },
      :session_timeout => 20 }
    if options
      @defaults.merge( options )
    end
    @defaults
  end

  def self.default_user_settings( options=nil )
    @default_user_settings || @default_user_settings = { }
    if options
      @default_user_settings.merge( options )
    end
    @default_user_settings
  end

  module Rails
    require 'tas10box/rails/engine'
    require 'tas10box/version'
  end

end