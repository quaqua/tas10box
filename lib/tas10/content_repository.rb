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
        max_versions 30
        include Mongoid::Paranoia

        include AccessControl
        include Labeling::InstanceMethods

        field :name, type: String
        field :label_ids, type: Array, default: []
        field :pos, type: Integer, default: 99
        field :acl, type: Hash, default: {}
        field :starred, type: Boolean, default: false

        index name: 1
        index label_ids: 1

        before_save :remove_plain_label_ids, :update_log, :check_write_permission
        after_save :share_children_on_change, :unshare_children_on_change
        before_create :setup_creator
        before_destroy :check_delete_permission

        embeds_many :log_entries

        validates_presence_of :name

        attr_accessor :user

      end

      def with_user( user )
        q = [{ :"acl.#{user.id}.privileges" => /r\w*/ }]
        user.group_ids.each do |group_id|
          q.push({:"acl.#{group_id.to_s}.privileges" => /r\w*/})
        end
        where( "$or" => q )
      end

      def first_with_user( user )
        doc = with_user( user ).first
        return unless doc
        doc.user = user
        doc
      end

      def all_with_user( user )
        docs = with_user( user ).all
        return unless docs
        docs.each do |doc|
          doc.user = user
        end
        docs
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
        self.log_entries.build :user => @user, :changes => previous_changes
      end

      def setup_creator
        raise InvalidUserError unless @user
        share( @user, 'rwsd' )
        #self.acl[:"#{@user.id}"] = { :privileges => "rwsd", :inherited => nil }
      end

      def reload
        return self.class.with_user( @user ).where( :id => id ).first
      end
      
      def remove_plain_label_ids
        self.label_ids = [] if self.label_ids == "[]"
      end

    end

    include InstanceMethods

    def self.included(model)
      model.extend ClassMethods
      model.extend Labeling::ClassMethods
      model.acts_as_document
    end

    def with_user( user )
      @user = user if user.is_a?( User )
      self
    end

  end

end
