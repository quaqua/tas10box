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
#gem 'tas10web', :git => 'ssh://tastenbox@digitalnova.tastenwerk.com/home/tastenbox/git-repos/tas10web.git'
#gem 'tas10crm', :git => 'ssh://tastenbox@digitalnova.tastenwerk.com/home/tastenbox/git-repos/tas10crm.git'

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

create_file 'config/mongoid.yml' do
  <<-eos
development:
  sessions:
    default:
      database: #{app_name}_development
      hosts:
        - localhost:27017
      options:
        safe: false
        consistency: :strong
  options:
    allow_dynamic_fields: false
    include_type_for_serialization: true
    scope_overwrite_exception: true
test:
  sessions:
    default:
      database: #{app_name}_test
      hosts:
        - localhost:27017
      options:
        consistency: :strong
production:
  sessions:
    default:
      database: #{app_name}_production
      hosts:
        - localhost:27017
      options:
        safe: false
        consistency: :strong
  options:
    allow_dynamic_fields: false
    identity_map_enabled: true
    include_root_in_json: false
    include_type_for_serialization: true
    scope_overwrite_exception: true
    raise_not_found_error: false
  eos
end

create_file 'config/tas10box.yml' do
  <<-eos
site:
  name: '#{app_name}'
  domain_name: 'localhost.loc'
  
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

route "root :to => 'Dashboard#index'"

# clean up rails defaults
remove_file 'public/index.html'
remove_file 'rm public/images/rails.png'
remove_file 'rm app/assets/images/rails.png'
get 'https://raw.github.com/quaqua/tas10box/master/vendor/assets/images/logo_150x150.png', 'app/assets/images/logo_150x150.png'
get 'https://raw.github.com/quaqua/tas10box/master/favicon.ico', 'public/favicon.ico'
run "echo '*.swp' >> .gitignore"
run "echo '.DS_Store' >> .gitignore"
run "echo 'datastore' >> .gitignore"
run "echo 'tas10box.yml*' >> .gitignore"

# commit to git
git :init
git :add => "."
git :commit => "-a -m 'create initial application'"

run 'rake tas10box:setup'

say <<-eos
  ============================================================================
  Your new Rails application is ready to go.
  
  Don't forget to scroll up for important messages from installed generators.
eos