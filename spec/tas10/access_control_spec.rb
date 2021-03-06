require 'spec_helper'
require 'digest/sha2'
require 'mongoid'

describe "Access Control" do

  before(:all) do
    PlainDoc.delete_all
    Tas10::User.delete_all
    @a = Tas10::User.create( :email => 'b@test.com' )
    @b = Tas10::User.create( :email => 'a@test.com' )
    @doc1 = PlainDoc.create_with_user( @a, :name => 'doc1' )
  end

  it "User a can find their own document" do
    PlainDoc.with_user( @a ).first.name.should == 'doc1'
  end

  it "Other user can't find document" do
    PlainDoc.with_user( @b ).first.should == nil
  end

  it "returns privileges on this document for document holding user" do
    @doc1.privileges.should == 'rwsd'
  end

  it "User a can read doc1" do
    @doc1.can_read?( @a ).should == true
  end

  it "User b cannot read doc1" do
    @doc1.can_read?( @b ).should == false
  end
    
  it "User a can write doc1" do
    @doc1.can_write?( @a ).should == true
  end

  it "User b cannot write doc1" do
    @doc1.can_write?( @b ).should == false
  end

  it "User b can share doc1" do
    @doc1.can_share?( @b ).should == false
  end

  it "User b cannot share doc1" do
    @doc1.can_share?( @b ).should == false
  end
    
  it "User a shares doc1 with user b" do
    @doc1.share( @b, 'r' )
    @doc1.save.should == true
  end

  it "User b can now read doc1" do
    @doc1.can_read?( @b ).should == true
  end

  it "User b can fetch doc1 from repository" do
    d1 = PlainDoc.first_with_user( @b )
    d1.name.should == @doc1.name
  end

  it "User b cannot write to doc1" do
    d1 = PlainDoc.first_with_user( @b )
    d1.privileges.should == 'r'
    d1.can_write?.should == false
  end

  it "User b cannot save doc1 changes to repository" do
    d1 = PlainDoc.where(:name => @doc1.name).first_with_user( @b )
    d1.name ='other'
    lambda{ d1.save }.should raise_error( Tas10::SecurityTransgressionError )
  end

  it "User b cannot delete doc1 regularly" do
    d1 = PlainDoc.where(:name => @doc1.name).first_with_user( @b )
    lambda{ d1.destroy }.should raise_error( Tas10::SecurityTransgressionError )
  end

  it "User b can access hierarchical content of a -> b -> c up to c" do
    a, b, c = setup_deep_hierarchical_struct( @a )
    a.share( @b, 'rws' )
    c.can_read?( @b ).should == false
    a.save.should == true
    c.reload.can_read?( @b ).should == true
  end

  it "User b can access hierarchical content a -> b -> c, if b, c is created after user b got access to a" do
    @doc1.share( @b, 'rwsd' )
    @doc1.save.should == true
    @doc1.can_read?( @b ).should == true
    b, c, d = setup_deep_hierarchical_struct( @a, @doc1.id )
    b.can_read?( @b ).should == true
  end

  it "If User b is deleted all access privileges are deleted as well" do
    @doc1.reload.can_read?( @b ).should == true
    @doc1.acl.size.should == 2
    @b.destroy.should == true
    @doc1.reload.acl.size.should == 1
  end

  it "defines classes which should give access to this subclass by copy_access_from class method" do
    PlainSubDoc.copy_access_from_objects.size.should == 1
    PlainSubDoc.copy_access_from_objects.first.should == :plain_doc
  end

  it "defines classes which should inherit acl to this subclass by copy_access_to class method" do
    PlainDoc.copy_access_to_objects.size.should == 1
    PlainDoc.copy_access_to_objects.first.should == :plain_sub_docs
  end

end
