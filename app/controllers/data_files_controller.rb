class DataFilesController < Tas10boxController

  before_filter :authenticate, :except => [:show, :thumb]

  def create
    @data_file = DataFile.new(params[:data_file]).with_user( current_user )
    puts "TRYING TO SAVF FUCKING FILE"
    if @data_file.save
      flash[:notice] = t('data_files.uploaded', :name => @data_file.name, :label => (@data_file.parent ? @data_file.parent.name : '/'))
    else
      flash[:error] = t('data_files.uploading_failed', :name => @data_file.name)
    end
    render :json => {
                    :flash => { :notice => [flash[:notice]], :error => [flash[:error]] },
                    :success => !flash[:notice].nil?,
                    :error => !flash[:error].nil?,
                    :reason => flash[:error],
                    :file => @data_file
                    }.to_json
  end

  def show
    if @data_file = get_user_or_id_data_file
      if ['.jpg','.jpeg','.png','.gif'].include?( @data_file.content_type.downcase )
        send_file(@data_file.filename,
                  :filename => @data_file.name,
                  :disposition => 'inline')
      else
        send_file(@data_file.filename,
                  :filename => @data_file.name,
                  :disposition => 'attachment')
      end
    else
      raise Error404
    end
  end

  def thumb
    if @data_file = get_user_or_id_data_file
      size = "16x16"
      if params[:size]
        if params[:size].include? 'x'
          size = params[:size]
        else
          size = "#{params[:size]}x#{params[:size]}"
        end
      end
      filename = "#{@data_file.filepath}/thumb_#{size}.#{Tas10box::defaults[:post_processor][:image_format] || 'png'}"
      #begin
        send_file(filename,
                  :type => "image/#{Tas10box::defaults[:post_processor][:image_format] || 'png'}",
                  :filename => @data_file.name,
                  :disposition => 'inline')
      #rescue
      #  logger.error "image #{filename} could not be found"
      #  render :text => ""
      #end
    else
      raise Error404
    end
  end

  private

  def get_user_or_id_data_file
    if authenticated?
      DataFile.where(:id => params[:id]).first_with_user( current_user )
    else
      DataFile.where(:id => params[:id]).first_with_user( anybody )
    end
  end

end