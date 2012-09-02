class QueryScript < Tas10::Document

  field :globals
  field :columns, type: Array
  field :body
  field :doc_type
  field :query

end