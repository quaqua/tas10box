require 'spec_helper'

describe "Ancestors" do

  before(:all) do
    PlainDoc.delete_all
    Tas10::User.delete_all
    @a = Tas10::User.create( :email => 'b@test.com' )
    @doc1 = PlainDoc.create_with_user( @a, :name => 'doc1' )
    @doc2 = PlainDoc.create_with_user( @a, :name => 'doc2' )
    @doc3 = PlainDoc.create_with_user( @a, :name => 'doc3' )
    @doc1.labels << @doc2
    @doc2.labels << @doc3
    @doc1.save
    @doc2.save
  end

  it "returns a row of ancestors (via following always the first label" do
    @doc1.ancestors.map{ |a| a.id }.should == [@doc3.id, @doc2.id]
  end

end
