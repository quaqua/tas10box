class DataFilesController < Tas10boxController

  before_filter :authenticate, :except => [:show, :thumb]

  def create
    if params[:qqfile]
      ext = File::extname(params[:qqfile])
      name = File::basename params[:qqfile]
      #label_ids = params[:label_ids].blank? ? [] : [ Moped::BSON::ObjectId(params[:label_ids]) ]
      @data_file = DataFile.new(:name => name, :label_ids => params[:label_ids],
        :file => request.body, :content_type => ext).with_user( current_user )
      if @data_file.save
        flash[:notice] = t('data_files.uploaded', :name => @data_file.name, :label => (@data_file.parent ? @data_file.parent.name : '/'))
      else
        flash[:error] = t('data_files.uploading_failed', :name => @data_file.name)
      end
    else
      flash[:error] = 'something terribly went wrong!'
    end
    render :json => {:file => @data_file,
                    :flash => { :notice => [flash[:notice]], :error => [flash[:error]] },
                    }.to_json
  end

  def show
    if @data_file = get_user_or_id_data_file
      send_file(@data_file.filename,
                :type => "image/#{Tas10box::defaults[:post_processor][:image_format] || 'png'}",
                :filename => @data_file.name,
                :disposition => 'inline')
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