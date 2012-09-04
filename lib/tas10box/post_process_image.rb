require 'RMagick' unless ENV['RAILS_ENV'] == 'test'

module Tas10box
  module PostProcessImage
    def self.run(blob)
      if blob.content_type.downcase.match(/png|jpg|jpeg|gif/)
        thumb_sizes = ['16x16','50x50','100x100'] + (Tas10box::defaults[:post_processor][:default_thumb_sizes] || [])
        thumb_sizes.each do |thumbsize|
          create_thumb(blob, thumbsize)
        end
      end
    end

    private

    def self.create_thumb(blob, thumbsize)
      x, y = thumbsize.split('x').map{ |ts| ts.to_i }
      return unless File::exists?( blob.filename )
      img = Magick::Image.read( blob.filename ).first
      img.format = Tas10box::defaults[:post_processor][:image_format] || "PNG"
      img.crop_resized!(x, y, Magick::CenterGravity)
      thumbname = "#{File::dirname(blob.filename)}/thumb_#{thumbsize}.#{Tas10box::defaults[:post_processor][:image_format] || 'png'}" #{File::extname(blob.name)}"
      img.write(thumbname)
    end

  end

end
