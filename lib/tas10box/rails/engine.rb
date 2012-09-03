module Tas10box

  class Tas10boxEngine < ::Rails::Engine

    tas10js = %w( tas10box.js )
    tas10css = %w( tas10box.css )

    if ENV['RAILS_ENV'] == 'production'
      initializer :assets do |config|
        ::Rails.application.config.assets.precompile += tas10js
        ::Rails.application.config.assets.precompile += tas10css
      end
    end

    initializer "tas10box_initializer"  do |app|


      require File::expand_path("../../controller_extensions", __FILE__)
      #require File::expand_path("../../post_process_image", __FILE__)
      ActionController::Base.send :extend,  Tas10box::ControllerExtensions::ClassMethods
      ActionController::Base.send :include, Tas10box::ControllerExtensions::InstanceMethods

      Mime::Type.register_alias "text/html", :m # mobile devices
      Mime::Type.register_alias "text/html", :snippet # html snippets (usually rendered as partials but to have them in views available)
      
      Tas10box::try_load_tas10box_config

      Tas10box.register_plugin ::Tas10box::NavBarPlugin.new( :name => 'home' )
      Tas10box.register_plugin ::Tas10box::NavBarPlugin.new( :name => 'history' )
      Tas10box.register_plugin ::Tas10box::Plugin.new( :name => 'labels', :creates => true )
    end


  end
end

