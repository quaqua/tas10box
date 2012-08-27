require 'spec_helper'

describe "Labeling" do

  before(:all) do
    PlainDoc.delete_all
    Tas10::User.delete_all
    @a = Tas10::User.create( :email => 'b@test.com' )
    @doc1 = PlainDoc.create_with_user( @a, :name => 'doc1' )
    @doc2 = PlainDoc.create_with_user( @a, :name => 'doc2' )
    @doc3 = PlainDoc.create_with_user( @a, :name => 'doc3' )
  end

  it "doc1 can be labeled with doc2" do
    @doc1.children.size.should == 0
    @doc1.children.push @doc2
    @doc1.children.size.should == 1
  end

  it "doc2 finds its labels" do
    @doc2 = @doc2.reload
    @doc2.labels.size.should == 1
    @doc2.labels.first.id.should == @doc1.id
  end

  it "doc1 finds it's children" do
    @doc1.children.size.should == 1
    @doc1.children.first.id.should == @doc2.id
  end

  it "doc3 gets labeled with doc2" do
    @doc3.labels.size.should == 0
    @doc3.labels.push @doc2
  end

  it "doc3 finds it's labels" do
    @doc3 = @doc3.reload
    @doc3.labels.size.should == 1
    @doc3.labels.first.id.should == @doc2.id
  end

end
