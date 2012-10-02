class PreferencesController < Tas10boxController

  before_filter :authenticate

  def index
  end

  def create
    @pref = Tas10::Preference.where(:name => params[:name], :plugin => params[:plugin]).first
    unless @pref
      @pref = Tas10::Preference.new(:name => params[:name], :plugin => params[:plugin])
      @pref.content = Tas10box::defaults[params[:name]]
    end
    content = params[params[:name].to_sym]
    if content.is_a?(Array) && content.first.index('{')
      content = []
      params[params[:name].to_sym].each do |p|
        content << eval(p)
      end
    end
    puts "got"
    puts content.inspect
    @pref.update(params[:name] => content)
    if @pref.save
      if params[:plugin] && Tas10box::defaults[params[:plugin]]
        p = Tas10box::defaults[params[:plugin]][params[:name]]
      else
        p = Tas10box::defaults[params[:name]]
      end
      if p.is_a?(Hash)
        p.merge! content
      else
        p = content
      end
      puts "SET: "
      puts Tas10box::defaults[params[:name]]
      puts ""
      flash[:notice] = t('saved', :name => params[:name])
    else
      flash[:error] = t('saving_failed', :name => params[:name])
    end
  end

end