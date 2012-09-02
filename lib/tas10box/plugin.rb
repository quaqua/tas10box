module Tas10box

  class Plugin

    attr_accessor :name, :creates, :label_templates, :query_script_type

    def initialize( attrs )
      if attrs.is_a?( Hash )
        attrs.each_pair do |key, value|
          self.send("#{key}=", value)
        end
      end
    end

  end

  class ApplicationPlugin < Plugin
    attr_accessor :double_click_action
  end

  class NavBarPlugin < Plugin
    attr_accessor :double_click_action
  end

end