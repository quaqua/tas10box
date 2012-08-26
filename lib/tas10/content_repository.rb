module Tas10

  module ContentRepository

    module ClassMethods

      # make this class acting as a document
      # this sets up required fields to be
      # acknowledged in the tas10core
      #
      def acts_as_document
        include Mongoid::Document
        include Mongoid::Versioning
        include Mongoid::Paranoia

        max_versions 30

        include AccessControl

        field :name, type: String
        field :label_ids, type: Array
        field :pos, type: Integer, default: 99
        field :acl, type: Hash, default: {}
        #field :log, type: Array, default: []
        field :comments, type: Array

        index name: 1
        index label_ids: 1

        before_save :update_log, :check_write_permission
        before_create :setup_creator
        before_destroy :check_delete_permission

        embeds_many :log_entries

        validates_presence_of :name

        attr_accessor :user

      end

      def with_user( user )
        where :"acl.#{user.id}.privileges" => /r\w*/
      end

      def first_with_user( user )
        doc = with_user( user ).first
        doc.user = user
        doc
      end

      def create_with_user( user, attrs )
        _creating do
          doc = new(attrs)
          doc.with_user( user )
          doc.save
          doc
        end
      end

    end


    module InstanceMethods

      def update_log
        self.log_entries.build :at => Time.now, 
          :user => @user,
          :changes => previous_changes
      end

      def setup_creator
        raise InvalidUserError unless @user
        share( @user, 'rwsd' )
        #self.acl[:"#{@user.id}"] = { :privileges => "rwsd", :inherited => nil }
      end

    end

    include InstanceMethods

    def self.included(model)
      model.extend ClassMethods
      model.acts_as_document
    end

    def with_user( user )
      @user = user if user.is_a?( Tas10::User )
      self
    end

  end

end
