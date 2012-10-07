module Tas10
  class Defaults

    def self.write( options )
      read
      @defaults.merge!( options )
    end

    def self.set( key, value )
      @defaults[key] = value if @defaults.has_key?(key)
    end

    def self.read
      @defaults ||= HashWithIndifferentAccess.new({ :locales => ["de", "en"],
        :site => { :name => 'My Company' },
        :session_timeout => 20,
        :datastore => File::join( ::Rails.root, 'datastore' ),
        :common => {
          :currency => "EUR",
          :delimiter => ","
        },
        :mail_system => {
          :sender => "noreply@tastenwerk.com"
        },
        :post_processor => {
          :default_thumb_sizes => ["100x100"],
          :image_format => "png"
        },
        :login => {
          :logo => "logo_150x150.png",
          :logo_border => "none"
        },
        :colors => [ '#aa9d73', '#6d87d6', '#22884f', '#bf4e30', '#85a000' ] })
      @defaults
    end

  end
end