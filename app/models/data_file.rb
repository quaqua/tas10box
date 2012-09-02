class DataFile < Tas10::Document

  field :content_type
  field :file_size, :type => Integer
  field :copyright
  field :description
  field :img_crop_pos

  before_save :determine_file_size
  after_save :save_to_datastore

  attr_accessor :file

  def filepath
    ::File::join( Tas10box::defaults[:datastore], id.to_s )
  end

  # returns full filename
  def filename
    ::File::join( filepath, id.to_s )
  end

  private

  def post_process_image
    return unless @file
    Tas10box::PostProcessImage.run(self.reload)
  end

  def determine_file_size
    return unless @file
    @file.rewind
    self.file_size = @file.read.size
  end

  def save_to_datastore
    return unless @file
    require 'fileutils'
    @file.rewind
    FileUtils::mkdir_p(File::dirname(filename)) unless File::exists?(File::dirname(filename))
    File::open(filename, "w+b") { |f| f.write(@file.read) }
    post_process_image
  end

  def permanently_remove_from_datastore
    require 'fileutils'
    FileUtils::rm_f(filename)
    if Dir.glob(File::dirname(filename)+'/*').size == 0
      FileUtils::rm_rf(File::dirname(filename))
    end
  end

end
