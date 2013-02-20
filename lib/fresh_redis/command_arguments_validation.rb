module FreshRedis

  module CommandArgumentsValidation
    class Argument
      attr_reader :name, :description

      TYPES = [:value, :flag].freeze

      def initialize(name, options = {})
        @name = String(name)
        @description = String(options[:description])
        @type = options.fetch(:type) { :value }.to_sym
        @validator_proc = options.fetch(:validator) { proc { nil } }
      end

      def validate!(value)
        error = @validator_proc[value]
        unless String(error).empty?
          raise ArgumentError, "Argument #@name is not valid: #{error}"
        end
      end

      TYPES.each do |type|
        define_method("#{type}?") { @type == type }
      end
    end

    class RequiredArgument < Argument
      def validate!(value)
        raise ArgumentError, "Argument #@name is required" if value.nil?
        super
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
      klass.send(:include, InstanceMethods)

      klass.instance_variable_set(:@arguments, Hash.new { |k| Argument.new(k) })
    end

    module ClassMethods
      attr_reader :arguments

      def inherited(klass)
        klass.instance_variable_set(:@arguments, arguments.dup)
      end

      def optional_argument(name, options = {})
        arguments[name] = Argument.new(name, options)
      end

      def required_argument(name, options = {})
        arguments[name] = RequiredArgument.new(name, options)
      end
    end

    module InstanceMethods
      def check_arguments!(arguments)
        self.class.arguments.each do |argument_name, argument|
          argument.validate! arguments[argument_name]
        end
      end
      private :check_arguments!
    end
  end

end

