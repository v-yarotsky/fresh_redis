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

  def cmd(base_class = TestSlab, &block)
    Class.new(TestSlab, &block)
  end

  test "ignores unspecified arguments" do
    assert_not_raises(ArgumentError) { TestSlab.new.validate(:foo => :bar) }
  end

  test "raises ArgumentError if validation fails" do
    klass = cmd { optional_argument(:foo, :validator => proc { |v| "Error" }) }
    assert_raises(ArgumentError) { klass.new.validate(:foo => 1) }
  end

  test "does not raise ArgumentError if validation does not fail" do
    klass = cmd { optional_argument(:foo, :validator => proc { |v| nil }) }
    assert_not_raises(ArgumentError) { klass.new.validate(:foo => 1) }
  end

  test "descendants don't overwrite parent's arguments" do
    klass1 = cmd { optional_argument(:foo, :validator => proc { |v| nil }) }
    klass2 = cmd(klass1) { optional_argument(:foo, :validator => proc { |v| "Error" }) }
    assert_not_raises(ArgumentError) { klass1.new.validate(:foo => 1) }
  end

  test "error message" do
    klass = cmd { optional_argument(:foo, :validator => proc { |v| "must be greater than 0" unless v > 0 }) }
    assert_raises_with_message(ArgumentError, "Argument foo is not valid: must be greater than 0") do
      klass.new.validate(:foo => -1)
    end
  end

  test "raises ArgumentError if required argument is absent" do
    klass = cmd { required_argument(:foo) }
    assert_raises_with_message(ArgumentError, "Argument foo is required") { klass.new.validate({}) }
  end

  test "uses validator on requried argument" do
    klass = cmd { required_argument(:foo, :validator => proc { |v| "SomeError" }) }
    assert_raises_with_message(ArgumentError, "Argument foo is not valid: SomeError") { klass.new.validate(:foo => 1) }
  end

  test "arguments are values by default" do
    klass = cmd { required_argument(:foo) }
    assert klass.arguments[:foo].value?, "Expected arguments to be values by default"
  end

  test "arguments can be flags" do
    klass = cmd { required_argument(:foo, :type => :flag) }
    assert klass.arguments[:foo].flag?, "Expected foo to be a flag"
    refute klass.arguments[:foo].value?, "Expected foo to be a flag, not value"
  end

  test "description is empty by default" do
    klass = cmd { required_argument(:foo) }
    assert_equal "", klass.arguments[:foo].description
  end

  test "can provide description" do
    klass = cmd { required_argument(:foo, :description => "Foo") }
    assert_equal "Foo", klass.arguments[:foo].description
  end

end

