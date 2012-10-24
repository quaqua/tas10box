require 'digest/sha2'

class Tas10::User
  include Mongoid::Document
  include Mongoid::Versioning

  max_versions 30

  field :name, type: String
  field :fullname, type: String
  field :email, type: String
  field :invited_by, type: String
  field :encrypted_password, type: String
  field :salt, type: String
  field :confirmation_key, type: String
  field :suspended, type: Boolean
  field :settings, type: Hash
  field :admin, type: Boolean

  embeds_many :user_log_entries
  embeds_many :comments, :class_name => "Tas10::Comment", :order => :created_at.desc

  validates_presence_of :email
  validates_format_of :email,
    :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
    :message => 'not a valid email address'
  validates_uniqueness_of :email

  validates :password, :confirmation => true,
                       :length => {:within => 6..40}, :if => '!password.nil?'

  has_and_belongs_to_many :known_users, class_name: "Tas10::User"
  has_and_belongs_to_many :groups, class_name: "Tas10::Group"
  has_many :audit_logs, class_name: "Tas10::AuditLog", order: :created_at.desc

  index( {:email => 1}, { :unique => true, :background => true } )
  index( {:name => 1}, { :background => true } )

  attr_accessor :password, :password_confirmation
  attr_protected :password, :admin

  # hooks
  before_save :encrypt_password
  before_create :generate_salt, :generate_password_if_none, :generate_confirmation_key, :setup_default_settings
  after_destroy :remove_acls

  def self.anybody_id
    Moped::BSON::ObjectId(24.times.inject(""){ |str,i| str << "0" })
  end

  def self.everybody_id
    Moped::BSON::ObjectId(24.times.inject(""){ |str,i| str << "1" })
  end

  def self.anybody
    anybody = new( :name => 'Anybody' )
    anybody._id = anybody_id
    anybody
  end

  def self.everybody
    everybody = new( :name => 'Everybody' )
    everybody._id = everybody_id
    everybody
  end

  def update_request_log( ip, url )
    self.user_log_entries.pop if self.user_log_entries.size > 50
    user_log_entries.where( :login => false ).all.delete
    user_log_entries.create( :ip => ip,
                              :url => url,
                              :created_at => Time.now )
    save(:safe => true)
  end

  def update_login_log( ip, url )
    self.user_log_entries.pop if self.user_log_entries.size > 50
    user_log_entries.create( :ip => ip,
                            :url => url,
                            :login => true,
                            :created_at => Time.now )
  end

  def match_password( pass )
    self.encrypted_password == encrypt( pass, self.salt )
  end

  def fullname_or_name
    fullname.blank? ? ( name.blank? ? email : name ) : fullname
  end

  def anybody?
    id == self.class.anybody_id
  end

  def photo_datastore_path
    ::File::join( Tas10box::defaults[:datastore], 'userpics', id.to_s )
  end

  # returns full filename
  def photo_datastore_filename
    ::File::join( photo_datastore_path, id.to_s )
  end

  def save_picture_to_datastore( file )
    require 'fileutils'
    file.rewind
    FileUtils::mkdir_p(photo_datastore_path) unless File::exists?(photo_datastore_path)
    File::open(photo_datastore_filename, "w+b") { |f| f.write(file.read) }
    Tas10box::PostProcessImage.userpic( photo_datastore_filename )
    true
  end

  private

  def encrypt( pass, salt )
    salt = "000a"
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
      self.password = SecureRandom.hex(4) + "1Aa"
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

  # remove acls set in any document if this user is destroyed permanently
  def remove_acls
    Tas10::Document.where(:"acl.#{id}.privileges" => /r\w*/ ).each do |doc|
      doc.versionless do
        doc.acl.delete(id.to_s)
        doc.save
      end
    end
  end

  #has_one :details, class: Tas10::Contact

  #documents implement later

end

