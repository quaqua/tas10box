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
      self.acl["#{user.id}"] = { "privileges" => privileges, "inherited" => nil, "invited" => @user.id, "at" => Time.now }
    end

    def privileges( user=@user )
      raise InvalidUserError if user.nil? || !user.is_a?(Tas10::User)
      self.acl["#{user.id}"] ? self.acl["#{user.id}"]["privileges"] : ''
    end

    def unshare( user )
      raise InvalidUserError if user.nil? || !user.is_a?(Tas10::User)
      self.acl.delete :"#{user.id}"
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

  end

end
