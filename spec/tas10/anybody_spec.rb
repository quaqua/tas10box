require 'spec_helper'
require 'digest/sha2'

describe "Anybody" do

  before(:all) do
    Tas10::User.delete_all
    Tas10::Document.delete_all
    @u = Tas10::User.create( :name => 'u' )
    @d = Tas10::Document.create_with_user( @u, :name => "doc1")
  end

  it "Tas10::User has anybody class method" do
    @u = Tas10::User.anybody.id == 24.times.inject(""){ |str,i| str << "0" }
  end

  it "can be looked up if anybody has access on a document" do
    @d.can_read?(Tas10::User.anybody).should == false
  end

  it "Tas10::User.anybody can do database lookups" do
    res = Tas10::Document.where(:id => @d.id).first_with_user( Tas10::User.anybody )
    res.should == nil
  end

  it "Tas10::User.anybody identifies itself with .anybody? method" do
    Tas10::User.anybody.anybody?.should == true
  end

  it "a document can be shared with anybody user" do
    @d.share( Tas10::User.anybody, 'r' )
    @d.save.should == true
    @d.can_read?(Tas10::User.anybody).should == true
  end

  it "Tas10::User.anybody can now find the document" do
    res = Tas10::Document.where(:id => @d.id).first_with_user( Tas10::User.anybody )
    res.name.should == @d.name
  end

  it "Tas10::User.anybody can not get write access when sharing" do
    @d.share( Tas10::User.anybody, 'rw' )
    @d.save.should == true
    @d.privileges( Tas10::User.anybody ).should == 'r'
  end

end