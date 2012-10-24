class Tas10::Message
  include Mongoid::Document
  
  belongs_to :author, :class_name => "Tas10::User", :inverse_of => nil
  field :content
  field :created_at, :type => Time, :default => ->{ Time.now }
  embedded_in :user, :class_name => "Tas10::User", :inverse_of => :messages
  
end