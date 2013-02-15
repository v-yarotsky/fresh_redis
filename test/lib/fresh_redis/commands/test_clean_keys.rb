require 'test_helper'
require 'fresh_redis/commands/clean_keys'

include FreshRedis::Commands

class TestCleanKeys < FreshRedisTestCase
  test "sanity" do
    assert_equal 1, 1
  end
end

