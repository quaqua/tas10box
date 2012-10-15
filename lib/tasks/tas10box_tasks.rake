namespace :tas10 do

  namespace :box do 
    description = "tas10box install script. sets up manager user and websites if configured"
    desc description
    task :setup => :environment do
      admins = Tas10::Group.where(:name => 'admins').first
      if admins
        puts " \033[31mexists\033[0m #{admins.name}"
      else
        admins = Tas10::Group.create(:name => 'admins')
        puts " \x1b[36mcreated\x1b[0m #{admins.name}"
      end

      user = Tas10::User.where(:name => 'manager').first
      if user
        puts " \033[31mexists\033[0m #{user.name}"
      else
        mgr = Tas10::User.new(:email => "manager@#{Tas10box::defaults[:site][:domain_name]}", :name => 'manager' )
        mgr.password = 'Manager1'
        mgr.password_confirmation = 'Manager1'
        mgr.admin = true
        mgr.groups.push( admins )
        if mgr.save
          puts " \x1b[36mcreated\x1b[0m #{mgr.name}"
        else
          puts " \033[36mfailed\033[0m #{mgr.errors.messages.inspect}"
        end
      end

      anybody = Tas10::User.where(:id => Tas10::User.anybody_id).first
      unless anybody
        anybody = Tas10::User.new(:name => 'anybody', :email => "anybody@#{Tas10box::defaults[:site][:domain_name]}")
        anybody._id = Tas10::User.anybody_id
        if anybody.save
          puts " \x1b[36mcreated\x1b[0m #{anybody.name}"
        else
          puts " \033[36mfailed\033[0m #{anybody.errors.messages.inspect}"
        end
      end

    end

  end
  
end
