module FreshRedis
  module Commands
    def self.commands
      constants.reject { |c| c == :BaseCommand }.map { |c| const_get(c) }
    end
  end
end

require 'fresh_redis/commands/clean_keys_command'

