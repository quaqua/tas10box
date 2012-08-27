require 'spec_helper'
require 'digest/sha2'
require File::expand_path '../../../app/models/user', __FILE__
require 'mongoid'

describe "Plain Document" do

  before(:all) do
    PlainDoc.delete_all
    Tas10::User.delete_all
    @user = Tas10::User.create( :email => 'test@test.com' )
    @buser = Tas10::User.create( :email => 'best@test.com' )
    @doc1 = PlainDoc.create_with_user( @user, :name => 'doc1' )
  end

  before(:each) do
    @plaindoc = PlainDoc.new
  end

  it "defines a new PlainDoc" do
    plain = PlainDoc.new
    plain.class.should == PlainDoc
  end

  it "validates name attribute before saving" do
    @plaindoc.save.should == false
  end

  it "has a with_user method to set up user to work with" do
    PlainDoc.respond_to?(:with_user).should == true
  end

  it "sets the given user for new PlainDocument" do
    pd = PlainDoc.new.with_user( @user )
    pd.class.should == PlainDoc
    pd.user.should_not == nil
    pd.user.class.should == Tas10::User
    pd.user.id.class.should == Moped::BSON::ObjectId
  end

  it "takes the given user and sets up a first log entry of the object" do
    pd = PlainDoc.new(:name => 'pd1').with_user( @user )
    pd.log_entries.size.should == 0
    pd.run_before_callbacks :save
    pd.log_entries.size.should == 1
    pd.log_entries[0].at.class.should == ActiveSupport::TimeWithZone
  end

  it "sets up default acl for creator" do
    pd = PlainDoc.new(:name => 'pd1').with_user( @user )
    pd.acl.size.should == 0
    pd.run_before_callbacks :create
    pd.acl.size.should == 1
    pd.acl["#{@user.id}"]["privileges"].should == 'rwsd'
  end

  it "creates a new document and saves it to the repository" do
    pd = PlainDoc.new(:name => 'pd2').with_user( @user )
    pd.save.should == true
  end

  it "creates a document via the create_with_user method" do
    pd = PlainDoc.create_with_user( @user, :name => 'pd3' )
    pd.class.should == PlainDoc
  end

  it "finds a document via with_user method " do
    pd = PlainDoc.with_user( @user ).where(:name => 'pd3').first
    pd.class.should == PlainDoc
    pd.name.should == 'pd3'
  end

  it "won't let another user find a document, where user has no privileges" do
    pd = PlainDoc.with_user( @buser ).first
    pd.should == nil
  end

  it "won't save if no user object is passed properly" do
    pd = PlainDoc.new(:name => 'p').with_user( 1 )
    lambda{ pd.run_before_callbacks(:create) }.should raise_error( Tas10::InvalidUserError )
  end

  it "reloads itself completely from the database" do
    PlainDoc.with_user( @user ).where(:name => 'doc1').inc(:pos, 1)
    @doc1.pos.should == 99
    doc1 = @doc1.reload
    doc1.pos.should == 100
  end

end
