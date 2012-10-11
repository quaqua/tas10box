class PlainDoc < Tas10::Document
  has_many :plain_sub_docs
  copy_access_to :plain_sub_docs
end
