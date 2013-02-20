require 'fresh_redis/commands'
require 'fresh_redis/command_optparse_decorator'
require 'optparse'
require 'redis'

module FreshRedis

  class Cli
    SUBCOMMANDS = Hash[Commands.commands.map { |c| [c.name, CommandOptparseDecorator.decorate(c)] }]

    def initialize(args)
      @args = args.dup
    end

    def run!
      parse_global_options!(@args)
      command_name = @args.shift or raise ArgumentError, "Specify command"
      subcommand = subcommands[command_name.to_sym] or raise ArgumentError, "Unknown command: #{command_name}"

      command_options = subcommand.parse_options!(@args)
      subcommand.new(command_options).run(redis)
    rescue SystemExit
      # Do nothing
    rescue Exception => e
      STDERR.puts "An error occurred: #{e.message}.\nRun #{File.basename $0} [COMMAND] --help"
      if ENV["DEBUG"]
        STDERR.puts e.backtrace
        raise
      end
      exit 1
    end

    private

    def parse_global_options!(args)
      @options = {
        :redis => {
          :host => "localhost",
          :port => 6379,
          :path => nil,
          :password => nil,
          :db => 0
        }
      }

      OptionParser.new do |opts|
        opts.banner = <<-USAGE
Usage: #{File.basename $0} [global_options] COMMAND [command_options]

Available commands: #{subcommands.keys.join(", ")}

        USAGE

        opts.separator "Redis options:"

        opts.on("--host", "-h HOSTNAME", "Redis host. Default: localhost")   { |v| @options[:redis][:host] = v }
        opts.on("--port", "-p PORT", Integer, "Redis port. Default: 6379")   { |v| @options[:redis][:port] = v }
        opts.on("--socket", "-s SOCKET", "Redis socket")                     { |v| @options[:redis][:path] = v }
        opts.on("--password", "-a PASSWORD", "Redis password")               { |v| @options[:redis][:password] = v }
        opts.on("--db", "-n DB_NUMBER", "Redis database number. Default: 0") { |v| @options[:redis][:password] = v }
      end.order!(args)
    end

    def redis
      @redis ||= Redis.new(@options[:redis])
    end

    def subcommands
      SUBCOMMANDS
    end
  end

end
