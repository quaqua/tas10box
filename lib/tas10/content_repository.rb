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

        before_save :remove_plain_entries, :check_write_permission, :update_log
        after_save :update_audit, :share_children_on_change, :unshare_children_on_change
        before_create :setup_creator, :check_access_inheritance
        before_destroy :check_delete_permission, :update_destroy_log

        embeds_many :log_entries, order: :created_at.desc

        validates_presence_of :name

        attr_accessor :user, :skip_audit

      end

      def with_user( user )
        q = [{ :"acl.#{user.id}.privileges" => /r\w*/ },
             { :"acl.#{Tas10::User.everybody_id}.privileges" => /r\w*/ },
             { :"acl.#{Tas10::User.anybody_id}.privileges" => /r\w*/ }]
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
        docs = with_user( user ).all.to_a
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
        return if skip_audit || @user.nil?
        c = changed
        c.delete('version')
        c.delete('label_ids')
        self.log_entries.order_by(:created_at.asc)[1].destroy if self.log_entries.size > 10
        self.log_entries.build :user => @user, :changed_fields => c
      end

      def update_audit
        return if skip_audit || @user.nil?
        if new_record?
          Tas10::AuditLog.create!( :user => @user, :document => self, :action => 'audit.created' )
        else
          c = changed
          c.delete('version')
          c.delete('label_ids')
          keys = { :user => @user, :document => self, :changed_fields => c }
          keys[:action] = 'audit.modified'
          if c.include? "name"
            keys[:action] = 'audit.renamed'
            keys[:additional_message] = name_change.join(' -> ') if name_change
          elsif c.include? "published"
            if published?
              keys[:action] = 'audit.published'
            else
              keys[:action] = 'audit.locked'
            end
          end
          Tas10::AuditLog.create!( keys )
        end
      end

      def update_destroy_log
        Tas10::AuditLog.create!( :user => @user, :document => self, :action => 'audit.deleted' )
      end

      def setup_creator
        raise InvalidUserError unless @user
        share( @user, 'rwsd' )
        #self.acl[:"#{@user.id}"] = { :privileges => "rwsd", :inherited => nil }
      end

      def reload
        return self.class.where( :id => id ).first_with_user( @user )
      end
      
      def remove_plain_entries
        self.template = nil if defined?(self.template) && self.template && self.template.match(/none|keine/)
        self.label_ids = [] if label_ids == "[]"
        if self.label_ids.is_a?(String)
          self.label_ids = self.label_ids.split(',')
          self.label_ids.each_with_index do |label_id, i|
            self.label_ids[i] = Moped::BSON::ObjectId(label_id) if label_id.is_a?(String)
          end
        end
      end

    end

    include InstanceMethods

    def self.included(model)
      model.extend ClassMethods
      model.extend Labeling::ClassMethods
      model.extend AccessControlClassMethods
      model.acts_as_document
    end

    def with_user( user )
      @user = user if user.is_a?( User )
      self
    end

  end

end
