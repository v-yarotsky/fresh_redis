require 'rubygems'
require 'minitest/autorun'
require "minitest/pride"
$:.unshift File.expand_path('../../lib', __FILE__)

class FreshRedisTestCase < MiniTest::Unit::TestCase
  # def default_test
  #   # Make Test::Unit happy...
  # end

  def self.test(name, &block)
    raise ArgumentError, "Example name can't be empty" if String(name).empty?
    block ||= proc { skip "Not implemented yet" }
    define_method "test #{name}", &block
  end

  def assert_raises_with_message(error, message)
    caught_message = nil
    begin
      yield
    rescue error => e
      caught_message = e.message
    end
    assert_equal message, caught_message
  end

  def assert_not_raises(*errors)
    yield
  rescue *errors => e
    raise "Expected #{errors.inspect} not to be raised, but raised #{e.message}"
  end

  def assert_requires_argument(klass, argument_name, test_value)
    assert_raises(ArgumentError) { klass.arguments[argument_name.to_sym].validate!(test_value) }
  end
end

