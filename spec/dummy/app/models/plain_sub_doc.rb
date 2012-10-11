class PlainSubDoc < Tas10::Document
  belongs_to :plain_doc
  copy_access_from :plain_doc
end