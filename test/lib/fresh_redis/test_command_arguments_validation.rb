require 'test_helper'
require 'fresh_redis/command_arguments_validation'

include FreshRedis

class TestCommandArgumentsValidation < FreshRedisTestCase
  class TestSlab
    include CommandArgumentsValidation

    def validate(arguments)
      check_arguments!(arguments)
    end
  end

  test "ignores unspecified arguments" do
    assert_not_raises(ArgumentError) do
      TestSlab.new.validate(:foo => :bar)
    end
  end

  test "raises ArgumentError if validation fails" do
    klass = Class.new(TestSlab) { check_argument(:foo) { |arg| false } }
    assert_raises(ArgumentError) { klass.new.validate(:foo => 1) }
  end

  test "does not raise ArgumentError if validation does not fail" do
    klass = Class.new(TestSlab) { check_argument(:foo) { |arg| true } }
    assert_not_raises(ArgumentError) { klass.new.validate(:foo => 1) }
  end

  test "descendants don't overwrite parent's arguments" do
    klass1 = Class.new(TestSlab) { check_argument(:foo) { |arg| true } }
    klass2 = Class.new(klass1) { check_argument(:foo) { |arg| false } }
    assert_not_raises(ArgumentError) { klass1.new.validate(:foo => 1) }
  end

  test "error message" do
    klass = Class.new(TestSlab) { check_argument(:foo, "must be greater than 0") { |v| v > 0 } }
    assert_raises_with_message(ArgumentError, "Argument foo is not valid: must be greater than 0") do
      klass.new.validate(:foo => -1)
    end
  end

end

