class Tas10::Preference
  include Mongoid::Document

  field :name
  field :plugin

  field :content, type: Hash

end

