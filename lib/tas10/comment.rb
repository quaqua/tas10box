class Tas10::Comment
  include Mongoid::Document
  
  belongs_to :user, :class_name => "Tas10::User"
  field :content
  field :created_at, :type => Time, :default => ->{ Time.now }
  embedded_in :document, :class_name => "Tas10::Document", :inverse_of => :comments
  embedded_in :user, :class_name => "Tas10::User", :inverse_of => :comments
  
end