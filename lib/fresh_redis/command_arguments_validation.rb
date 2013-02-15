module FreshRedis

  module CommandArgumentsValidation
    class ArgumentValidator
      def self.noop(name)
        new(name, &proc { |value| false })
      end

      def initialize(name, message = "", &validator_proc)
        @name = String(name)
        @message = String(message)
        @validator_proc = validator_proc || proc { true }
      end

      def call(value)
        @validator_proc[value] or raise ArgumentError, "Argument #@name is not valid: #{ @message.empty? ? "unknown reason" : @message }"
      end
      alias_method :[], :call
    end

    def self.included(klass)
      klass.extend(ClassMethods)
      klass.send(:include, InstanceMethods)

      klass.instance_variable_set(:@required_arguments, Hash.new { |k| ArgumentValidator.noop(k) })
    end

    module ClassMethods
      attr_reader :required_arguments

      def inherited(klass)
        klass.instance_variable_set(:@required_arguments, required_arguments.dup)
      end

      def check_argument(name, error_message = "", &block)
        required_arguments[name] = ArgumentValidator.new(name, error_message, &block)
      end
    end

    module InstanceMethods
      def check_arguments!(arguments)
        self.class.required_arguments.each do |argument_name, validator|
          validator[arguments[argument_name]]
        end
      end
      private :check_arguments!
    end
  end

end

