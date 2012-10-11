require 'spec_helper'

describe "Label Inheritance Access Control" do

  before(:all) do
    PlainDoc.delete_all
    Tas10::User.delete_all
    @a = Tas10::User.create( :email => 'b@test.com' )
    @b = Tas10::User.create( :email => 'a@test.com' )
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

  it "gives access to all has_many relations on subdoc creation" do
    @doc1.plain_sub_docs.size.should == 0
    subdoc = PlainSubDoc.create_with_user( @a, :name => 'Oscar', :plain_doc => @doc1 )
    @doc1.plain_sub_docs.size.should == 1
    PlainSubDoc.where(:id => subdoc.id).first_with_user( @b ).name.should == 'Oscar'
  end

  it "unshares subdocs relations along with document" do
    d = PlainDoc.where(:id => @doc1.id).first_with_user( @a )
    d.unshare( @b )
    d.save.should == true
    d = PlainDoc.where(:id => @doc1.id).first_with_user( @a )
    d.can_read?( @b ).should == false
    PlainSubDoc.first_with_user( @a ).privileges(@b).should == ''
    PlainSubDoc.first_with_user( @b ).should == nil
  end

  it "gives access to all has_many relations" do
    d = PlainDoc.create_with_user( @a, :name => 'dd' )
    psd1 = PlainSubDoc.create_with_user( @a, :name => 'psd1', :plain_doc => d )
    PlainSubDoc.where(:id => psd1.id).first_with_user( @b ).should == nil
    d.share( @b, "rwsd" )
    d.save.should == true
    PlainSubDoc.where(:id => psd1.id).first_with_user( @b ).name.should == 'psd1'
  end

end
