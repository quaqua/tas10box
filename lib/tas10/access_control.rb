module Tas10

  module AccessControl

    # shares this document with given
    # user and privileges
    #
    # @param [ User ] the user to share this document with
    # @param [ String ] privileges r..read,w..write,s..share,d..delete
    #
    # @returns [ TrueClass ] if everything goes fine
    #
    def share( user, privileges )
      raise InvalidUserError if user.nil? || !user.is_a?(Tas10::User)
      unless new_record?
        raise InvalidUserError if @user.nil? || !user.is_a?(Tas10::User)
        return false unless can_share?
      end
      self.acl["#{user.id}"] = { "privileges" => privileges, "inherited" => {}, "invited" => (new_record? ? nil : @user.id), "at" => Time.now }
    end

    def privileges( user=@user )
      raise InvalidUserError if user.nil? || !user.is_a?(Tas10::User)
      self.acl["#{user.id}"] ? self.acl["#{user.id}"]["privileges"] : ''
    end

    def unshare( user )
      raise InvalidUserError if user.nil? || !user.is_a?(Tas10::User)
      self.acl.delete "#{user.id}"
    end

    def can_share?( user=@user )
      raise InvalidUserError if user.nil? || !user.is_a?(Tas10::User)
      privileges(user).include? 's'
    end

    def can_write?( user=@user )
      raise InvalidUserError if user.nil? || !user.is_a?(Tas10::User)
      privileges(user).include? 'w'
    end

    def can_delete?( user=@user )
      raise InvalidUserError if user.nil? || !user.is_a?(Tas10::User)
      privileges(user).include? 'd'
    end

    def can_read?( user=@user )
      raise InvalidUserError if user.nil? || !user.is_a?(Tas10::User)
      privileges(user).include? 'r'
    end

    def check_write_permission
      return if new_record?
      raise SecurityTransgressionError unless can_write?
    end

    def check_delete_permission
      raise SecurityTransgressionError unless can_delete?
    end

    def share_children_on_change
      return unless acl_changed? && acl.size > 1 # in case of new_record creation
      share_children
    end

    def unshare_children_on_change
      unshare_children if acl_was && acl_was.size > acl.size
    end

    def share_children
      children.each do |child|
        collect_positive_changes.each_pair do |u_id, acl|
          if child.acl[u_id]
            if child.acl[u_id]["privileges"].size < acl["privileges"].size
              child.acl[u_id]["privileges"] = acl["privileges"]
            end
            child.acl[u_id]["inherited"][self.id.to_s] = acl["privileges"]
          else
            acl["inherited"] = {self.id.to_s => acl["privileges"]}
            child.acl[u_id] = acl
          end
        end
        child.save
      end
    end

    def unshare_children
      children.each do |child|
        collect_negative_changes.each do |u_id|
          if child.acl[u_id]
            if child.acl[u_id]["inherited"].size > 1
              child.acl[u_id]["inherited"].delete(self.id.to_s)
              child.acl[u_id]["privileges"] = child.acl[u_id]["inherited"].last[1]
            else
              child.acl.delete(u_id)
            end
          end
        end
        child.save
      end
    end

    private

    def collect_positive_changes
      return @positive_changes if @positive_changes
      @positive_changes = {}
      acl_change.last.each_pair do |u_id, v|
        @positive_changes[u_id] = v unless (acl_was.include? u_id)
      end
      @positive_changes
    end

    def collect_negative_changes
      return @negative_changes if @negative_changes
      @negative_changes = []
      acl_was.each_pair do |u_id, v|
        @negative_changes << u_id unless acl_change.last.include?(u_id)
      end
      @negative_changes
    end

  end

end
