require 'test_helper'
 
class ActsAsDocumentTest < ActiveSupport::TestCase

	setup do
		@plaindoc = PlainDoc.new
	end

  test "has a name value " do
  	assert_nil @plaindoc.name
  end

  test "has a pos (position) value " do
  	assert_equal @plaindoc.pos, 99
  end

  test "has an acl hash " do
  	assert_nil @plaindoc.acl
  end

  test "has a log array " do
  	assert_nil @plaindoc.logs
  end

  test "has an label_ids array " do
  	assert_nil @plaindoc.label_ids
  end

end