namespace :tas10box do
  description = "tas10box install script. sets up manager user and websites if configured"
  desc description
  task :setup => :environment do
    admins = Group.first
    if admins
      puts " \033[31mexists\033[0m #{admins.name}"
    else
      admins = Group.create(:name => 'admins')
      puts "\x1b[36mcreated\x1b[0m #{admins.name}"
    end

    user = User.first
    if user
      puts " \033[31mexists\033[0m #{user.name}"
    else
      mgr = User.new(:email => 'manager@localhost.loc', :name => 'manager' )
      mgr.password = 'mgr'
      mgr.groups.push( admins )
      if mgr.save
        puts " \x1b[36mcreated\x1b[0m #{mgr.name}"
      else
        puts " \033[36mfailed\033[0m #{mgr.errors.messages.inspect}"
      end
    end
  end
end
