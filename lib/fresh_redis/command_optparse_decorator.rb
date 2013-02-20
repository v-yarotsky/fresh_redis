require 'optparse'

module FreshRedis

  module CommandOptparseDecorator
    def self.decorate(command_class)
      command_class.extend(self)
    end

    def parse_options!(args)
      options = {}
      option_parser(options).order!(args)
      options
    end

    private

    def option_parser(mutable_options)
      @option_parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename $0} [global_options] #{name} [options]"
        arguments.each do |argument_name, argument|
          opts.on(option_parser_string_for_argument(argument), argument.description) { |v| mutable_options[argument_name] = v }
        end
      end
    end

    def option_parser_string_for_argument(argument)
      long_option_name = argument.name.to_s.gsub('_', '-')

      if argument.flag?
        "--#{long_option_name}"
      elsif argument.value?
        "--#{long_option_name} VALUE"
      else
        raise "Don't know how to ask for #{argument.name}"
      end
    end
  end

end
