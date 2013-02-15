require 'fresh_redis/command_arguments_validation'

module FreshRedis
  module Commands

    class BaseCommand
      include CommandArgumentsValidation

      class << self
        attr_reader :description

        def description(description)
          @description = description.dup
        end
      end

      def initialize(arguments = {})
        check_arguments!(arguments)
        @arguments = arguments
      end

      def description
        String(self.class.description)
      end

      def run(redis)
        raise NotImplementedError
      end
    end

  end
end

