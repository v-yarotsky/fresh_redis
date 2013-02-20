module FreshRedis

  module CommandArgumentsValidation
    class Argument
      attr_reader :name, :description

      TYPES = [:value, :flag].freeze

      def initialize(name, options = {})
        @name = String(name)
        @description = String(options[:description])
        @type = options.fetch(:type) { :value }.to_sym
        @converter_proc = options.fetch(:converter) { proc { |v| v } }
        @validator_proc = options.fetch(:validator) { proc { nil } }
      end

      def value(v)
        @converter_proc[v]
      end

      def validate!(v)
        error = @validator_proc[value(v)]
        unless String(error).empty?
          raise ArgumentError, "Argument #@name is not valid: #{error}"
        end
      end

      TYPES.each do |type|
        define_method("#{type}?") { @type == type }
      end
    end

    class OptionalArgument < Argument
      def initialize(name, options = {})
        super
        @default_value = options[:default]
      end

      def value(v)
        v.nil? ? @default_value : super
      end
    end

    class RequiredArgument < Argument
      def validate!(v)
        raise ArgumentError, "Argument #@name is required" if value(v).nil?
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
        arguments[name] = OptionalArgument.new(name, options)
      end

      def required_argument(name, options = {})
        arguments[name] = RequiredArgument.new(name, options)
      end
    end

    module InstanceMethods
      private

      attr_reader :arguments

      def initialize(*)
        @arguments = {}
        super
      end

      def arguments=(passed_arguments)
        self.class.arguments.each do |argument_name, argument_spec|
          argument_spec.validate! passed_arguments[argument_name]
        end
        @arguments = passed_arguments
      end

      def argument(name)
        self.class.arguments[name.to_sym].value(arguments[name])
      end
    end
  end

end

