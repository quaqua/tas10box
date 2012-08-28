class Tas10::Document
  include ::Tas10::ContentRepository

  embeds_many :comments, :class_name => "Tas10::Comment", :order => :created_at.desc

end
