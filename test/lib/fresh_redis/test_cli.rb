require 'test_helper'
require 'fresh_redis/cli'

include FreshRedis

class TestCli < FreshRedisTestCase
  test "help shows available commands"
  test "does not print stacktrace by default"
  test "prints stacktrace if ENV['DEBUG'] is set"
  test "requires command"
  test "complains if command is unknown"
  test "runs command"
end


