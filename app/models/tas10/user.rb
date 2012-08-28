require 'digest/sha2'

class Tas10::User
  include Mongoid::Document
  include Mongoid::Versioning
  include Mongoid::Paranoia

  max_versions 30

  field :name, type: String
  field :fullname, type: String
  field :email, type: String
  field :encrypted_password, type: String
  field :salt, type: String
  field :confirmation_key, type: String
  field :suspended, type: Boolean
  field :settings, type: Hash
  field :admin, type: Boolean

  embeds_many :user_log_entries

  validates_presence_of :email
  validates_format_of :email,
    :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
    :message => 'not a valid email address'

  has_many :known_users, class_name: "Tas10::User"
  has_and_belongs_to_many :groups, class_name: "Tas10::Group"

  index( {:email => 1}, { :unique => true, :background => true } )
  index( {:name => 1}, { :background => true } )

  attr_accessor :password
  attr_protected :password

  # hooks
  before_save :encrypt_password
  before_create :generate_salt, :generate_password_if_none, :generate_confirmation_key, :setup_default_settings

  def update_request_log( ip, url )
    user_log_entries.create( :ip => ip,
                              :url => url,
                              :at => Time.now )
    save(:safe => true)
  end

  def update_login_log( ip, url )
    user_log_entries.create( :ip => ip,
                            :url => url,
                            :login => true,
                            :at => Time.now )
  end

  def match_password( pass )
    self.encrypted_password == encrypt( pass, self.salt )
  end

  def fullname_or_name
    fullname.blank? ? ( name.blank? ? email : name ) : fullname
  end
  
  private

  def encrypt( pass, salt )
    Digest::SHA256::hexdigest( pass + salt )
  end

  # encrypt the password in combination
  # with the previously generated salt
  #
  def encrypt_password
    generate_salt unless self.salt
    unless self.password.blank?
      self.encrypted_password = encrypt( self.password, self.salt )
    end
  end

  # generate a password salt
  # to be mixed in when password is
  # encrypted. This will only be generated once (on create)
  #
  def generate_salt
    self.salt = SecureRandom.hex(2) if new_record?
  end

  # if no password was given on creation, a dummy one
  # will be created, so no bad guy can log in with no 
  # password
  #
  def generate_password_if_none
    if password.blank? && new_record?
      self.password = SecureRandom.hex(4)
    end
  end

  # generates a confirmation key (20digits)
  # This key can later be used to reset a password
  # or for first-time login
  #
  def generate_confirmation_key
    if new_record?
      self.confirmation_key = SecureRandom.hex(10)
    end
  end

  def setup_default_settings
    self.settings = Tas10box::default_user_settings
  end

  #has_one :details, class: Tas10::Contact

  #documents implement later

end

