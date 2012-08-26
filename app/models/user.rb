require 'digest/sha2'
require File::expand_path '../group', __FILE__

class Tas10::User
	include Mongoid::Document
  include Mongoid::Versioning
  include Mongoid::Paranoia

  max_versions 30

	field :name, type: String
	field :email, type: String
	field :log, type: Array
	field :actions, type: Array
	field :encrypted_password, type: String
  field :salt, type: String
  field :confirmation_key, type: String
	field :settings, type: Hash

  has_and_belongs_to_many :groups
  has_many :log_entries

  validates_presence_of :email
  validates_format_of :email,
    :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
    :message => 'not a valid email address'

	has_many :known_users, class_name: "Tas10::User"

  index( {:email => 1}, { :unique => true, :background => true } )
  index( {:name => 1}, { :background => true } )

	attr_accessor :password
  attr_protected :password

  # hooks
	before_save :encrypt_password
  before_create :generate_salt, :generate_password_if_none, :generate_confirmation_key

  private

  # encrypt the password in combination
  # with the previously generated salt
  #
	def encrypt_password
    unless self.password.blank?
  		self.encrypted_password = Digest::SHA256::hexdigest( self.password + self.salt )
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

	#has_one :details, class: Tas10::Contact

	#documents implement later

end

