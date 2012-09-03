class DataFilesController < Tas10boxController

  before_filter :authenticate

  def create
    if params[:qqfile]
      ext = File::extname(params[:qqfile])
      name = File::basename params[:qqfile]
      #label_ids = params[:label_ids].blank? ? [] : [ Moped::BSON::ObjectId(params[:label_ids]) ]
      @data_file = DataFile.new(:name => name, :label_ids => params[:label_ids],
        :file => request.body, :content_type => ext).with_user( current_user )
      if @data_file.save
        flash[:notice] = t('data_file.uploaded', :name => @data_file.name, :to => (@data_file.parent ? @data_file.parent.name : '/'))
      else
        flash[:error] = t('data_file.uploading_failed', :name => @data_file.name)
      end
    else
      flash[:error] = 'something terribly went wrong!'
    end
    render :json => {:name => @data_file.name, 
                    :size => @data_file.file_size, 
                    :url => data_file_path(@data_file), 
                    :delete_url => data_file_path(@data_file),
                    :id => @data_file.id,
                    :flash => { :notice => flash[:notice], :error => flash[:error] },
                    }.to_json
  end

  def thumb
    @data_file = DataFile.where(:id => params[:id]).first_with_user( current_user )
    if @data_file
      size = "#{params[:size]}x#{params[:size]}" || "16x16"
      filename = "#{@data_file.filepath}/thumb_#{size}.#{Tas10box::defaults[:post_processor][:image_format] || 'png'}"
      puts "filename #{filename}"
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
      render :text => t('insufficient_rights')
    end
  end

end