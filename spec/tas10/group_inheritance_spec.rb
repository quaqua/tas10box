require 'spec_helper'

describe "Group Inheritance Access Control" do

  before(:all) do
    PlainDoc.delete_all
    Tas10::User.delete_all
    Tas10::Group.delete_all
    @a = Tas10::User.create(:email => 'a@test.com')
    @b = Tas10::User.create(:email => 'b@test.com')
    @g = Tas10::Group.create(:name => 'g')
    @a.groups.push( @g )
    @b.groups.push( @g )
    @doc1 = PlainDoc.create_with_user( @a, :name => 'doc1' )
  end

  it "a document can be shared with a group" do
    @doc1.privileges( @b ).should == ''
    @doc1.share( @g, 'r' )
    @doc1.save.should == true
    @doc1.privileges( @b ).should == 'r'
  end

  it "a document can be found when shared with group" do
    pd = PlainDoc.first_with_user( @b )
    pd.id.should == @doc1.id
  end

end
