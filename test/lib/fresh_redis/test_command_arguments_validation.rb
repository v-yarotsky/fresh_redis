require 'test_helper'
require 'fresh_redis/command_arguments_validation'

include FreshRedis

class TestCommandArgumentsValidation < FreshRedisTestCase
  class TestSlab
    include CommandArgumentsValidation

    def initialize(arguments)
      self.arguments = arguments
    end

    public :argument
  end

  def cmd(base_class = TestSlab, &block)
    Class.new(TestSlab, &block)
  end

  test "ignores unspecified arguments" do
    assert_not_raises(ArgumentError) { TestSlab.new(:foo => :bar) }
  end

  test "raises ArgumentError if validation fails" do
    klass = cmd { optional_argument(:foo, :validator => proc { |v| "Error" }) }
    assert_raises(ArgumentError) { klass.new(:foo => 1) }
  end

  test "does not raise ArgumentError if validation does not fail" do
    klass = cmd { optional_argument(:foo, :validator => proc { |v| nil }) }
    assert_not_raises(ArgumentError) { klass.new(:foo => 1) }
  end

  test "descendants don't overwrite parent's arguments" do
    klass1 = cmd { optional_argument(:foo, :validator => proc { |v| nil }) }
    klass2 = cmd(klass1) { optional_argument(:foo, :validator => proc { |v| "Error" }) }
    assert_not_raises(ArgumentError) { klass1.new(:foo => 1) }
  end

  test "error message" do
    klass = cmd { optional_argument(:foo, :validator => proc { |v| "must not be empty" if v.empty? }) }
    assert_raises_with_message(ArgumentError, "Argument foo is not valid: must not be empty") do
      klass.new(:foo => "")
    end
  end

  test "raises ArgumentError if required argument is absent" do
    klass = cmd { required_argument(:foo) }
    assert_raises_with_message(ArgumentError, "Argument foo is required") { klass.new({}) }
  end

  test "uses validator on requried argument" do
    klass = cmd { required_argument(:foo, :validator => proc { |v| "SomeError" }) }
    assert_raises_with_message(ArgumentError, "Argument foo is not valid: SomeError") { klass.new(:foo => 1) }
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

  test "default value for optional argument" do
    klass = cmd { optional_argument(:foo, :default => "Foo") }
    assert_equal "Foo", klass.arguments[:foo].value(nil)
  end

  test "converter" do
    klass = cmd { optional_argument(:foo, :converter => proc { |v| v.to_i }) }
    assert_equal 1, klass.arguments[:foo].value("1")
  end

  test "converts value before validation" do
    validatable_value = nil
    klass = cmd { optional_argument(:foo, :converter => proc { |v| v.to_i }, :validator => proc { |v| validatable_value = v; nil }) }
    klass.arguments[:foo].validate!("1")
    assert_equal 1, validatable_value
  end

  test "#argument" do
    klass = cmd { optional_argument(:foo, :converter => proc { |v| v.to_i }) }
    inst = klass.new(:foo => 1)
    assert_equal 1, inst.argument(:foo)
  end

end

