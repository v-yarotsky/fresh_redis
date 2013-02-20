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

        def name
          raise NotImplementedError
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

    ##
    # Creates a base class for command with defined .name method
    def self.Command(name)
      Class.new(BaseCommand).tap do |c|
        c.define_singleton_method(:name) { name.to_sym }
      end
    end
  end

end

