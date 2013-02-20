require 'fresh_redis/commands/base_command'
require 'ruby-progressbar'

module FreshRedis
  module Commands

    class CleanKeysCommand < Command(:clean_keys)
      description "Specify key wildcard to delete all matching keys"

      required_argument :key_pattern,
                        :description => "pattern for redis KEYS command",
                        :validator => proc { |value| "Key pattern can not be empty" if String(value).empty? }

      optional_argument :batch_size,
                        :default => 1000,
                        :converter => proc { |value| value.to_i },
                        :validator => proc { |value| "Batch size must be a positive numeric value" unless value > 0 }

      def run(redis)
        puts "Fetching keys like \"#{argument(:key_pattern)}\""
        keys = redis.keys(argument(:key_pattern))

        if keys.length == 0
          puts "Nothing to clean"
          return
        end

        init_progress(keys.size)

        keys.each_slice(argument(:batch_size)) do |keys_slice|
          redis.pipelined { keys_slice.each { |key| redis.del(key) } }
          increment_progress(keys.size, keys_slice.compact.size)
        end
      end

      private

      def init_progress(total_elements)
        @progress = ProgressBar.create(:format => "%t: %p%% [%B] [%c / %C] Elapsed %a %f", :total => total_elements)
      end

      def increment_progress(total_elements, increment)
        @progress.progress += increment
      end
    end

  end
end

