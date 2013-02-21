require 'test_helper'
require 'fresh_redis/command_options'

include FreshRedis

class TestCommandOptions < FreshRedisTestCase
  class TestCommand
    extend CommandOptions

    attr_accessor :attributes

    def self.name; :test; end

    def initialize(attributes)
      self.attributes = attributes
    end
  end

  test ".options defines how options are parsed" do
    klass = Class.new(TestCommand) do
      options do |opts, attributes|
        opts.on("--test VAL") { |v| attributes[:test] = v }
      end
    end

    inst = klass.new_from_args(["--test", "foo"])
    assert_equal "foo", inst.attributes[:test]
  end

  test "help mentions command name" do
    klass = Class.new(TestCommand) { options { |opts, attrs| } }
    assert_match /test/, klass.send(:create_option_parser).help
  end
end

