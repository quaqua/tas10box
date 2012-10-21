module Tas10

  module Labeling

    module ClassMethods

      # returns all documents that are not labeled with any other document
      #
      def roots
        query = where(:label_ids => [])
      end

    end

    module InstanceMethods

      def root?
        label_ids == []
      end

      # get ancestors of this child label
      # and returns a list with labels starting
      # with very the top-most label right after
      # the root label
      # 
      # @returns [Array] list of ancestors starting with the top-most label right
      # after the root
      #
      def ancestors
        ancs = []
        if labels.first
          ancs << labels.first
          ancs += labels.first.ancestors
        end
        ancs.reverse
      end

      # return all documents, who are labeled with this document
      #
      # @returns [ Tas10::DocumentArray ]
      #
      def children(reload=:no)
        return @children_cache if @children_cache && reload != :reload
        query = Tas10::Document.where( :label_ids => id )
        @children_cache = DocumentArray.new( self, @user, query )
      end

      # return all documents this document is labeled with
      #
      # @param [ Hash ] options hash: { :reload => false }
      #
      # @returns [ Tas10::DocumentArray ]
      #
      def labels(reload=:no)
        return @labels_cache if @labels_cache && reload != :reload
        query = Tas10::Document.with_user( @user ).in( :id => label_ids )
        @labels_cache = DocumentArray.new( self, @user, query, true )
      end

      # returns the first label in the label_ids list of the
      # document. This label is associated as the document's
      # parent
      def parent
        return unless label_ids.size > 0
        Tas10::Document.where( :id => label_ids.first ).first_with_user( @user )
      end

      def nullify_children
        children.each do |doc|
          doc.label_ids.delete( id )
          doc.save
        end
      end

      def destroy_children
        children.each do |doc|
          doc.destroy
        end
      end

    end

  end

end
