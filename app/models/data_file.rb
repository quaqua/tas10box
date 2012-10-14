class DataFile < Tas10::Document

  field :content_type
  field :file_size, :type => Integer
  field :copyright
  field :description
  field :img_crop_pos
  field :extension
  field :published, :type => Boolean, :default => false

  before_validation :setup_file, :on => :create
  after_save :save_to_datastore
  after_destroy :delete_file

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
    Tas10box::PostProcessImage.run(self.reload)
  end

  def setup_file
    return unless file
    self.name = file.original_filename
    self.content_type = file.content_type
    puts "GOT FILE"
    determine_file_size
  end

  def determine_file_size
    file.tempfile.rewind
    self.file_size = file.tempfile.read.size
  end

  def save_to_datastore
    return unless file
    require 'fileutils'
    file.tempfile.rewind
    FileUtils::mkdir_p(File::dirname(filename)) unless File::exists?(File::dirname(filename))
    self.extension = File::extname(filename)
    File::open(filename, "w+b") { |f| f.write(file.tempfile.read) }
    post_process_image
  end

  def permanently_remove_from_datastore
    require 'fileutils'
    FileUtils::rm_rf(File::dirname(filename))
  end

  def delete_file
    if !destroyed?
      permanently_remove_from_datastore
    end
  end

end
