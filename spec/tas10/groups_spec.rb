require 'spec_helper'

describe "Users Groups" do

  before(:all) do
    User.delete_all
    Group.delete_all
    @u = User.create(:email => 'u@test.com')
    @g = Group.create(:name => 'g')
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
