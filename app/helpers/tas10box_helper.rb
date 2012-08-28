module Tas10boxHelper

  def get_tas10box_plugin_options( key, include_none=true )
    options = []
    options << ['', t('none')] if include_none
    Tas10box.plugins.each do |plugin|
      if plugin.label_templates
        plugin.label_templates.each do |template|
          options << ["#{plugin.name}/template", t("#{plugin.name} : #{template}")]
        end
      end
    end
    options
  end

end