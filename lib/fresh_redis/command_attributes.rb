module FreshRedis

  class CommandAttributes
    class RequiredAttributeMissingError < StandardError; end

    def initialize
      @defaults = {}
      @required = []
      @values = {}
    end

    def [](name)
      @values.key?(name) ? @values[name] : @defaults[name]
    end

    def []=(name, value)
      @values[name] = value
    end

    def require(name)
      @required << name
    end

    def default(name, value)
      @defaults[name] = value
    end

    def validate!
      diff = (@required - @values.keys)
      unless diff.empty?
        raise RequiredAttributeMissingError, "The following required attributes were not specified: #{diff.join(", ")}"
      end
    end
  end

end

