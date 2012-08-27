require 'spec_helper'

describe "Users Groups" do

  before(:all) do
    Tas10::User.delete_all
    Tas10::Group.delete_all
    @u = Tas10::User.create(:email => 'u@test.com')
    @g = Tas10::Group.create(:name => 'g')
  end

  it "a user can have many groups" do
    @u.groups.size.should == 0
    @u.groups.push( @g )
    @u.groups.size.should == 1
  end

  it "a group finds it's according users" do
    @g.users.first.id.should == @u.id
  end

end
