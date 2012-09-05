require 'digest/sha2'
#require 'securerandom'

class Tas10::Group
  include Mongoid::Document

  field :name, type: String

  validates_presence_of :name

  has_and_belongs_to_many :users, :class_name => "Tas10::User"

  def fullname_or_name
    name
  end

end

