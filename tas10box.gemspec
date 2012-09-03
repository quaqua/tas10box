$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "tas10box/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tas10box"
  s.version     = Tas10box::VERSION
  s.authors     = ["thorsten zerha"]
  s.email       = ["thorsten.zerha@tastenwerk.com"]
  s.homepage    = "http://tastenwerk.com"
  s.summary     = "tas10box is a visual framework"
  s.description = "visual framework for mongodb as a content repository"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"
  s.add_dependency "haml-rails", ">= 0.3.4"
  #s.add_dependency "kaminari", "0.12.4" # pagination for mongoid
  s.add_dependency "i18n-js"
  s.add_dependency "rmagick"

  s.add_development_dependency "rspec-rails"

end
