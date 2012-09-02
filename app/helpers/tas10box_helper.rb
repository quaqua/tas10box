module Tas10boxHelper

  def get_tas10box_plugin_options( key, include_none=true )
    options = []
    options << ['', t('none')] if include_none
    Tas10box.plugins.each do |plugin|
      if plugin.label_templates
        plugin.label_templates.each do |template|
          options << [t("#{plugin.name}.#{template}"), "#{plugin.name}/templates/label_#{template}"]
        end
      end
    end
    options
  end

  def get_options_for_query_script_types
    options = []
    Tas10box.plugins.each do |plugin|
      options << [t("#{plugin.name}.title"), plugin.name] if plugin.query_script_type
    end
    options
  end

end