require 'spec_helper'

describe "Label Inheritance Access Control" do

  before(:all) do
    PlainDoc.delete_all
    User.delete_all
    @a = User.create( :email => 'b@test.com' )
    @b = User.create( :email => 'a@test.com' )
    @doc1 = PlainDoc.create_with_user( @a, :name => 'doc1' )
    @doc2 = PlainDoc.create_with_user( @a, :name => 'doc2', :label_ids => [@doc1.id] )
    @doc3 = PlainDoc.create_with_user( @a, :name => 'doc3', :label_ids => [@doc2.id] )
  end

  it "doc1 -> doc2 -> doc3" do
    @doc1.children.first.id.should == @doc2.id
    @doc2.children.first.id.should == @doc3.id
  end

  it "sharing doc1 with another user shares all children as well" do
    @doc1.share( @b, 'r' )
    @doc1.save
    @doc2 = @doc2.reload
    @doc2.privileges(@b).should == 'r'
    @doc3 = @doc3.reload
    @doc3.privileges(@b).should == 'r'
  end

  it "unsharing doc1 with user @b unshares all children as well" do
    @doc1.unshare( @b )
    @doc1.save
    @doc2 = @doc2.reload
    @doc2.privileges(@b).should == ''
    @doc3 = @doc3.reload
    @doc3.privileges(@b).should == ''
  end

  it "labels.push inherits acl from label" do
    @doc1.share( @b, 'rw' )
    @doc1.save
    doc4 = PlainDoc.create_with_user( @a, :name => 'doc4' )
    doc4.labels.push @doc1
    doc4 = PlainDoc.where(:name => 'doc4').first_with_user( @a )
    doc4.labels.first.id.should == @doc1.id
    doc4.can_read?( @b ).should == true
  end

  it "children.push inherits acl to children" do
    @doc1.share( @b, 'rw' )
    @doc1.save
    doc5 = PlainDoc.create_with_user( @a, :name => 'doc5' )
    @doc1.children.push doc5
    doc5 = PlainDoc.where(:name => 'doc5').first_with_user( @a )
    doc5.labels.first.id.should == @doc1.id
    doc5.can_read?( @b ).should == true
  end

end
