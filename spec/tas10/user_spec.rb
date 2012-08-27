require 'spec_helper'
require 'digest/sha2'

describe "User" do

  before(:each) do
    @u = Tas10::User.new
  end

	it "new user can be defeind" do
		u = Tas10::User.new(:name => 'u1')
		u.class.should == Tas10::User
		u.name.should == 'u1'
	end

	it "a new user requires at least an email address" do
    @u.save.should == false
    @u.errors.messages[:email].include?("can't be blank").should == true
  end

	it "given email address must be valid" do
    @u.email = 'test'
    @u.save.should == false
    @u.errors.messages[:email].include?("not a valid email address").should == true
    @u.email = 'test@test.com'
    @u.save.should == true
  end

  it "password field cannot be set through mass assignment" do
    u = Tas10::User.create(:email => 'test@test.com', :password => 'test')
    u.password.should_not == 'test'
    u.password = 'test'
    u.password.should == 'test'
  end

  it "before a user is saved to the database, a password is generated, if none was set" do
    @u.password.should == nil
    @u.encrypted_password.should == nil
    @u.run_before_callbacks :create
    @u.password.class.should == String
  end

  it "autogenerated password has 8 digits" do
    @u.run_before_callbacks :create
    @u.password.size.should == 8
  end

  it "autogenerates a salt" do
    @u.run_before_callbacks :create
    @u.salt.class.should == String
    @u.salt.size.should == 4
  end

  it "encrypts the password of a user, if a password is given" do
    @u.run_before_callbacks :create, :save
    @u.encrypted_password.class.should == String
    @u.encrypted_password.should == Digest::SHA256::hexdigest( @u.password + @u.salt )
  end


end

