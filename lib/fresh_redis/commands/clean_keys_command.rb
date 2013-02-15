require 'fresh_redis/commands/base_command'

module FreshRedis
  module Commands

    class CleanKeysCommand < BaseCommand
      description <<-DESC
Specify key wildcard to clean
      DESC

      check_argument(:key_pattern) { |value| !String(value).empty? }

      def run(redis)
        keys = redis.keys(@arguments[:key_pattern])
        redis.pipelined do
          keys.each_slice(100000) do |keys_slice|
            keys_slice.each { |key| redis.del(key) }
          end
        end
      end
    end

  end
end

