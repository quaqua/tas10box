module Tas10boxHelper

  def get_tas10box_plugin_options( key, include_none=true )
    options = []
    options << [t('none'),''] if include_none
    Tas10box.plugins.each do |plugin|
      if plugin.label_templates
        plugin.label_templates.each do |template|
          options << [t("#{plugin.name}.#{template}"), "#{plugin.name}/templates/label_#{template}"]
        end
      end
    end
    options
  end

  def get_templates_for( plugin_name )
    if plugin_name == 'labels'
      return get_tas10box_plugin_options( :label_templates )
    end
    if Tas10box::defaults[:"#{plugin_name}"] && Tas10box::defaults[:"#{plugin_name}"][:templates]
      Tas10box::defaults[:"#{plugin_name}"][:templates]
    else
      []
    end
  end

  def get_label(label_id)
    Tas10::Document.where(:id => label_id).first_with_user( current_user )
  end

  def get_label_name(label_id)
    l = get_label label_id
    l ? l.name : 'not found'
  end

  def get_options_for_query_script_types
    options = []
    Tas10box.plugins.each do |plugin|
      options << [t("#{plugin.name}.title"), plugin.name] if plugin.query_script_type
    end
    options
  end

  def get_user_or_group_by_id( user_id )
    u = Tas10::User.where(:id => user_id).first
    u = Tas10::Group.where(:id => user_id).first unless u
    u
  end

  def get_known_users( user )
    return Tas10::User.order_by(:name.asc).all if user.id == current_user.id && user.admin?
    user.known_users
  end

  def get_known_groups( user )
    return Tas10::Group.all if user.id == current_user.id && user.admin?
    user.groups
  end

end