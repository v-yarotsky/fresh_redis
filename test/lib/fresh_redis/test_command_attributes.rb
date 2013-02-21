require 'test_helper'
require 'fresh_redis/command_attributes'

include FreshRedis

class TestCommandAttributes < FreshRedisTestCase
  def setup
    @attributes = CommandAttributes.new
  end

  test "acts as hash" do
    @attributes[:foo] = 1
    assert_equal 1, @attributes[:foo]
  end

  test "supports defaults" do
    @attributes.default(:foo, 2)
    assert_equal 2, @attributes[:foo]
  end

  test "doesn't apply default value if explicitly set to false" do
    @attributes.default(:foo, 1)
    @attributes[:foo] = false
    assert_equal false, @attributes[:foo]
  end

  test "doesn't apply default value if explicitly set to nil" do
    @attributes.default(:foo, 1)
    @attributes[:foo] = nil
    assert_equal nil, @attributes[:foo]
  end

  test "#validate! raises if required values are missing" do
    @attributes.require(:foo)
    assert_raises CommandAttributes::RequiredAttributeMissingError do
      @attributes.validate!
    end
  end

  test "#validate! does not raise if required values are present" do
    @attributes.require(:foo)
    @attributes[:foo] = 1
    assert_not_raises CommandAttributes::RequiredAttributeMissingError do
      @attributes.validate!
    end
  end
end

