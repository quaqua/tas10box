require 'test_helper'
require 'digest/sha2'
require File.expand_path("../../../app/models/user", __FILE__)

Tas10::User.delete_all

class UserTest < ActiveSupport::TestCase

  def setup
    @user = Tas10::User.new
  end

  test "has a name attribute" do
    assert_nil @user.name
  end

  test "has an email attribute" do
    assert_nil @user.email
  end

  test "has a log attribute" do
    assert_nil @user.log
  end

  test "has an encrypted password attribute" do
    assert_nil @user.encrypted_password
  end

  test "has a password attribute" do
    assert_nil @user.password
  end

  test "creates a new user object" do
    u = Tas10::User.create(:name => 'user1')
    assert_equal u.persisted?, true
  end

  test "finds the user" do
    u = Tas10::User.where(:name => 'user1').first
    assert_equal u.name, 'user1'
  end

  test "updates the user's name" do
    u = Tas10::User.where(:name => 'user1').first
    assert_equal u.update_attributes(name: 'user_1'), true
  end

  test "sets user's password to an encrypted password before saving" do
    u = Tas10::User.new(:name => 'user2', :password => 'pass')
    u.run_before_callbacks :save
    assert_equal Digest::SHA256::hexdigest('pass'), u.encrypted_password
  end

end