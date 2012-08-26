class PlainDoc
  include Mongoid::Document
  include Tas10box::ContentRepository

  acts_as_document

end
