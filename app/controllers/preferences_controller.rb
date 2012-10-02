class PreferencesController < Tas10boxController

  before_filter :authenticate

  def index
  end

  def create
    require 'yaml'
    params.each_pair do |key, value|
      next if %w( utf8 authenticity_token _ ).include?(key)
      if value.is_a?(Hash)
        value.each_pair do |k,v|
          if v.is_a?(Array)
            v.reject!{ |e| e.blank? }
            v.map!{ |a| a = eval(a) if a.include?("{") ; a }
          end
        end
      end
      Tas10box::defaults_set(key, value)
    end
    require 'fileutils'
    filename = File::join( Rails.root, "config", "tas10box.yml" )
    FileUtils::cp filename, "#{filename}_bak_#{Time.now.strftime('%Y-%m-%d_%H%M%S')}"
    File.open(filename, "w") do |f|
      f.write YAML::dump( Tas10box::defaults )
    end
    flash[:notice] = t('saved', :name => t('preferences.title') )
  end

end