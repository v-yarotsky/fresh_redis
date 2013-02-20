require 'test_helper'
require 'fresh_redis/commands/clean_keys_command'

include FreshRedis::Commands

class TestCleanKeys < FreshRedisTestCase
  test "requires key_pattern argument to be present" do
    assert_requires_argument CleanKeysCommand, :key_pattern, ""
  end

  test "has clean_keys as a name" do
    assert_equal :clean_keys, CleanKeysCommand.name
  end

  #TODO: find better way to test redis interaction
  #TODO: test batching
  #TODO: really test pipelined
  test "cleans matching keys in pipeline" do
    redis = Object.new
    class << redis
      attr_reader :removed_keys
      def keys(*); @keys ||= %w(test1 test2); end
      def pipelined; @pipelined = true; yield; end
      def del(key); (@removed_keys ||= []) << key; end
      def pipelined?; !!@pipelined; end
    end
    CleanKeysCommand.new(:key_pattern => "test*").run(redis)
    assert redis.pipelined?
    assert_equal %w(test1 test2), redis.removed_keys
  end
end

