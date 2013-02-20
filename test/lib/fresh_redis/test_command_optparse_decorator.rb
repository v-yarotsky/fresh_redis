require 'test_helper'
require 'fresh_redis/command_optparse_decorator'

require 'fresh_redis/commands/base_command'

include FreshRedis

class TestCommandOptparseDecorator < FreshRedisTestCase

  class SomeCommand < Commands.Command(:some_command)
    description "SomeCommand description"

    required_argument :foo
    required_argument :bar, :type => :flag, :description => "Bar description"
    optional_argument :baz
    optional_argument :dasherize_me
  end

  def cmd
    CommandOptparseDecorator.decorate(Class.new(SomeCommand))
  end

  test "prints corrent usage section for command" do
    help = cmd.send(:option_parser, {}).banner
    assert_match %r{Usage: .* \[global_options\] some_command \[options\]}, help
  end

  test "printes correct options summary" do
    help = cmd.send(:option_parser, {}).summarize.map { |s| s.squeeze(" ").strip }
    assert_equal ["--foo VALUE", "--bar Bar description", "--baz VALUE", "--dasherize-me VALUE"], help
  end

  test "parses options" do
    parsed = cmd.parse_options!(%w(--foo foo_value --bar --baz baz_value --dasherize-me dasherize_me_value))
    assert_equal({ :foo => "foo_value", :bar => true, :baz => "baz_value", :dasherize_me => "dasherize_me_value"}, parsed)
  end

end

