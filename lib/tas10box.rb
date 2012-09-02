module Tas10
end

require 'mongoid'
require File::expand_path '../../app/models/tas10/user', __FILE__
require 'tas10/errors'
require 'tas10/log_entry'
require 'tas10/user_setting'
require 'tas10/user_log_entry'
require 'tas10/comment'
require 'tas10/defaults'
require 'tas10/access_control'
require 'tas10/document_array'
require 'tas10/labeling'
require 'tas10/content_repository'
require 'tas10box/plugin'
require 'tas10box/post_process_image'

module Tas10box

  def self.plugins
    @plugins ||= []
  end

  def self.register_plugin( plugin )
    @plugins ||= []
    @plugins << plugin
  end

  def self.defaults( options=nil )
    options ? Tas10::Defaults::write( options ) : Tas10::Defaults::read
  end

  def self.root
    File::expand_path "../../", __FILE__
  end

  def self.default_user_settings( options=nil )
    @default_user_settings || @default_user_settings = { }
    if options
      @default_user_settings.merge( options )
    end
    @default_user_settings
  end

  def self.try_load_tas10box_config
    filename = File::join( ::Rails::root, "config", "tas10box.yml" )
    if File::exists? filename
      site_options = HashWithIndifferentAccess.new(YAML.load(File.read( filename )))
      Tas10box::defaults( site_options )
    else
      puts "no site options file found at #{filename}"
    end
  end

  module Rails
    require 'tas10box/rails/engine'
    require 'tas10box/version'
  end

end