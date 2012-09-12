# create rvmrc file
#create_file ".rvmrc", "rvm gemset use #{app_name}"

gem 'rails', '3.2.8'

gem 'sass-rails',   '~> 3.2.3', :group => [ :assets ]
gem 'coffee-rails', '~> 3.2.1', :group => [ :assets ]
gem 'uglifier', '>= 1.0.3', :group => [ :assets ]

gem 'jquery-rails'

gem 'mongoid'
gem 'unicorn'


gem 'tas10box', :git => 'git://github.com/quaqua/tas10box.git'
gem 'tas10web', :git => 'ssh://tastenbox@digitalnova.tastenwerk.com/home/tastenbox/git-repos/tas10web.git'
gem 'tas10crm', :git => 'ssh://tastenbox@digitalnova.tastenwerk.com/home/tastenbox/git-repos/tas10crm.git'

#gem 'tas10box', :path => '../tas10box'
#gem 'tas10crm', :path => '../tas10crm'
#gem 'tas10web', :path => '../tas10web'

gem 'haml-rails', '>= 0.3.4'
gem 'i18n-js'

gem 'tinymce-rails'

gem "rspec-rails", :group => [ :development, :test ]

run 'bundle install'

#rake "db:create", :env => 'development'
#rake "db:create", :env => 'test'
remove_file 'public/javascripts/rails.js' # jquery-rails replaces this
generate 'jquery:install --ui'
generate 'rspec:install'
generate 'mongoid:config'


#inject_into_file 'spec/spec_helper.rb', "\nrequire 'factory_girl'", :after => "require 'rspec/rails'"
inject_into_file 'config/application.rb', :after => "config.filter_parameters += [:password]" do
  <<-eos

    config.time_zone = 'Vienna'
    config.i18n.default_locale = :de
    config.i18n.fallbacks = true
    config.encoding = "utf-8"
    config.active_support.escape_html_entities_in_json = true
    config.assets.enabled = true
    config.assets.version = '1.0'

    Mongoid.logger.level = Logger::DEBUG
    Moped.logger.level = Logger::DEBUG
  eos
end
run "echo '--format documentation' >> .rspec"

create_file 'config/initializers/tas10_plugin_setup.rb' do
  <<-eos

    Rails.application.config.after_initialize do

      # Tas10box.register_plugin ::Tas10box::Plugin.new( :name => 'newstickers', 
      #   :creates => true,
      #   :label_templates => [ "newsticker" ] )

    end
  eos
end

create_file 'config/i18n-js.yml' do
  <<-eos
  
translations:
  - file: "public/javascripts/i18n/%{locale}.js"
    only: "*"
  eos
end

append_file 'config/initializers/backtrace_silencers.rb' do
  <<-eos

    if defined?(Rails) && (Rails.env == 'development')
      Rails.backtrace_cleaner.remove_silencers!
      Rails.logger = Logger.new(STDOUT)
    end
  eos
end

route "map.root :controller => :dashboard"

# clean up rails defaults
remove_file 'public/index.html'
remove_file 'rm public/images/rails.png'
run "echo '*.swp' >> .gitignore"
run "echo '.DS_Store' >> .gitignore"
run "echo 'datastore' >> .gitignore"

# commit to git
git :init
git :add => "."
git :commit => "-a -m 'create initial application'"

say <<-eos
  ============================================================================
  Your new Rails application is ready to go.
  
  Don't forget to scroll up for important messages from installed generators.
eos