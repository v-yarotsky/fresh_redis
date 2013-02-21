require 'optparse'
require 'fresh_redis/command_attributes'

module FreshRedis

  ##
  # Provides facility to get command attributes via command line
  #
  # requires .name method for usage section of help
  # require constructor to accept arguments hash
  #
  module CommandOptions
    def new_from_args(args)
      mutable_attributes = CommandAttributes.new
      option_parser = create_option_parser
      optparse_block.call(option_parser, mutable_attributes)
      option_parser.order!(args)
      mutable_attributes.validate!
      new(mutable_attributes)
    end

    private

    def create_option_parser
      option_parser = OptionParser.new
      option_parser.banner = "Usage: #{File.basename $0} [global_options] #{name} [command_options]"
      option_parser
    end

    ##
    # DSL method to configure OptionParser and populate command attributes
    #
    # Example:
    #
    # options do |opts, arguments|
    #   arguments.require(:foo)
    #   arguments.default(:foo, "Hello, world")
    #
    #   opts.on("--foo VALUE") do |v|
    #     raise "Value must be" if String(v).empty?
    #     arguments[:foo] = v
    #   end
    # end
    #
    def options(&block)
      @optparse_block = block
    end

    def optparse_block
      @optparse_block || proc {}
    end
  end

end

