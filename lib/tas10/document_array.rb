module Tas10

  class DocumentArray < Array

    def initialize( doc, user, query, labels_array=false )
      @doc = doc
      raise NotPersistedError if @doc.id.blank? || @doc.new_record?
      @user = user
      @query = query
      @loaded = false
      @labels_array = labels_array
      super()
    end

    attr_accessor :query

    def each
      run_query unless @loaded
      super
    end

    def first
      run_query unless @loaded
      super
    end

    def last
      run_query unless @loaded
      super
    end

    # push an existing document to this document's children
    # this is inversive equivalent to the label_with method
    def push( doc )
      raise InvalidDocumentError unless doc.id
      @labels_array ? push_to_label_ids( doc ) : push_to_doc_label_ids( doc )
      super( doc )
    end

    def size
      run_query unless @loaded
      super
    end

    private

    def run_query
      @loaded = true
      @query.all.each do |doc|
        doc.user = @user
        self<< doc
      end
    end

    def push_to_doc_label_ids( doc )
      return if doc.label_ids.include?( @doc.id )
      #doc.class.where(:id => doc.id).push(:label_ids, @doc.id)
      doc.label_ids << @doc.id
      inherit_access_control( @doc, doc )
      doc.save
    end

    def push_to_label_ids( doc )
      return if @doc.label_ids.include?( doc.id )
      @doc.label_ids << doc.id
      inherit_access_control( doc, @doc )
      @doc.save
    end

    def inherit_access_control( parent, child )
      parent.acl.each_pair do |u_id, pacl|
        if child.acl.include? u_id
          if pacl["privileges"].size > child.acl[u_id]["privileges"].size
            child.acl[u_id]["privileges"] = pacl["privileges"]
          end
          child.acl[u_id]["inherited"][parent.id] = pacl["privileges"]
        else
          pacl["inherited"] = { parent.id => pacl["privileges"] }
          child.acl[u_id] = pacl
        end
      end
    end

  end

end
