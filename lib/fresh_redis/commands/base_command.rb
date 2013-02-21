require 'fresh_redis/command_options'

module FreshRedis
  module Commands

    class BaseCommand
      extend CommandOptions

      class << self
        attr_reader :description

        def description(description)
          @description = description.dup
        end

        def name
          raise NotImplementedError
        end
      end

      def initialize(attributes = {})
        @attributes = attributes
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

