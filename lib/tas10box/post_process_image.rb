require 'RMagick' unless ENV['RAILS_ENV'] == 'test'

module Tas10box
  module PostProcessImage
    def self.run(blob)
      if blob.content_type.downcase.match(/png|jpg|jpeg|gif/)
        thumb_sizes = ['16x16','50x50','100x100'] + (Tas10box::defaults[:post_processor][:default_thumb_sizes] || [])
        thumb_sizes.each do |thumbsize|
          create_thumb(blob.filename, thumbsize)
        end
      end
    end

    def self.userpic( filename )
      thumb_sizes = ['16x16','20x20', '30x30', '50x50','100x100']
      thumb_sizes.each do |thumbsize|
        create_thumb(filename, thumbsize)
      end
    end

    private

    def self.create_thumb(filename, thumbsize)
      x, y = thumbsize.split('x').map{ |ts| ts.to_i }
      return unless File::exists?( filename )
      img = Magick::Image.read( filename ).first
      img.format = Tas10box::defaults[:post_processor][:image_format] || "PNG"
      if y
        img.crop_resized!(x, y, Magick::CenterGravity)
      else
        img.resize_to_fill!(x, x)
      end
      thumbname = "#{File::dirname(filename)}/thumb_#{thumbsize}.#{Tas10box::defaults[:post_processor][:image_format] || 'png'}"
      img.write(thumbname)
    end

  end

end
