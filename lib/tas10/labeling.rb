module Tas10

  module Labeling

    module ClassMethods

      # returns all documents that are not labeled with any other document
      #
      def roots( options={ :query => false } )
        query = where(:label_ids => [])
        return query.all unless options[:query]
      end

    end

    module InstanceMethods

      def root?
        label_ids == []
      end

      def ancestors( options={:reverse => false} )
        ancs = []
        ancs = get_ancs if label_ids.size > 0
        # ancs are in wrong order by default. :reverse option just keeps wrong order
        ancs.reverse! unless options[:reverse]
        ancs
      end

      # return all documents, who are labeled with this document
      #
      # @returns [ Tas10::DocumentArray ]
      #
      def children(reload=:no)
        return @children_cache if @children_cache && reload != :reload
        query = self.class.with_user( @user ).where( :label_ids => id )
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
        query = self.class.with_user( @user ).in( :id => label_ids )
        @labels_cache = DocumentArray.new( self, @user, query, true )
      end

      # returns the first label in the label_ids list of the
      # document. This label is associated as the document's
      # parent
      def parent
        self.class.with_user( @user ).where( :label_ids => id ).first
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

      private

      def get_ancs
        ancs << self.class.with_user( @user ).where( :id => label_ids.first )
        ancs << get_ancs( ancs.last.label_ids.first ) if ancs.last.label_ids.size > 0
        ancs
      end

    end

  end

end
