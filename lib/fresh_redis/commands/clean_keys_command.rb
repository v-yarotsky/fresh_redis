require 'fresh_redis/commands/base_command'
require 'ruby-progressbar'

module FreshRedis
  module Commands

    class CleanKeysCommand < Command(:clean_keys)
      description "Specify key wildcard to delete all matching keys"

      options do |opts, attributes|
        attributes.require(:key_pattern)
        attributes.default(:batch_size, 1000)

        opts.on("--key-pattern", "-k PATTERN", "Patter for redis KEYS command") do |v|
          raise OptionParser::InvalidArgument, "Key pattern can not be empty" if String(v).empty?
          attributes[:key_pattern] = v
        end

        opts.on("--batch-size", "-n NUM", Integer) do |v|
          raise OptionParser::InvalidArgument, "Batch size must be a positive numeric value" unless v > 0
          attributes[:batch_size] = v
        end
      end

      def run(redis)
        puts "Deleting keys matching \"#{@attributes[:key_pattern]}\""
        keys = redis.keys(@attributes[:key_pattern])

        if keys.length == 0
          puts "Nothing to clean"
          return
        end

        init_progress(keys.size)

        keys.each_slice(@attributes[:batch_size]) do |keys_slice|
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

