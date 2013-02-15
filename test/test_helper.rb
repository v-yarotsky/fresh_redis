require 'rubygems'
require 'test/unit'
$:.unshift File.expand_path('../../lib', __FILE__)

class FreshRedisTestCase < Test::Unit::TestCase
  def default_test
    # Make Test::Unit happy...
  end

  def self.test(name, &block)
    raise ArgumentError, "Example name can't be empty" if String(name).empty?
    block ||= proc { skip "Not implemented yet" }
    define_method "test #{name}", &block
  end
end

