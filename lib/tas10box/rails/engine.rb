module Tas10box

  class Tas10boxEngine < ::Rails::Engine

    initializer :assets do |config|
      #::Rails.application.config.assets.precompile += %w( tas10box.js tas10box.css jquery.Jcrop.min.js tas10box-mobile.js tas10box-mobile.css ) 
    end

    initializer "tas10box_initializer"  do |app|

      require File::expand_path("../../controller_extensions", __FILE__)
      #require File::expand_path("../../post_process_image", __FILE__)
      ActionController::Base.send :extend,  Tas10box::ControllerExtensions::ClassMethods
      ActionController::Base.send :include, Tas10box::ControllerExtensions::InstanceMethods

      Mime::Type.register_alias "text/html", :m # mobile devices
      Mime::Type.register_alias "text/html", :snippet # html snippets (usually rendered as partials but to have them in views available)
      
    end

  end
end

