class Tas10::Document
  include ::Tas10::ContentRepository

  default_scope order_by(:name => :asc)

  embeds_many :comments, :class_name => "Tas10::Comment", :order => :created_at.desc
  has_many :audit_logs, :class_name => "Tas10::AuditLog", :order => :created_at.desc

end
