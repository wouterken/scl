module Scl
  module Control
    class ControllerModule
      attr_reader :controller
      def initialize(controller)
        @controller = controller
      end

      def args
        @controller.args
      end

      def input_decoder
        @controller.input_decoder
      end

      def output_encoder
        @controller.output_encoder
      end

      def key_coder
        @controller.key_coder
      end

      def help?
        args.help
      end

      def self.help(message, method)
        @@help ||= {}
        @@help[self.name] ||= {}
        @@help[self.name][method.to_s] = message
      end

      def self.print_help(args, method, own_methods=[])
        module_name = self.name.split('::').last.downcase
        puts "======="
        if method && @@help[self.name] && @@help[self.name][method]
          puts "Usage: scl #{module_name} #{method} (options)\n"
          puts
          puts @@help[self.name][method].split("\n").map{|line| line.gsub(/^\s{6}/,'')}.join("\n")
          puts
        else
          puts "No help docs found for \"#{method}\"\n=======\n" if method
          puts "Usage: scl #{module_name} [command] (options)"
          puts
          puts "Supported commands are [#{own_methods.join(' ')}]"
          puts
          puts "Try scl #{module_name} [command] -h for more info"
          puts
          puts args.opts.to_s[/Where options.*/m]
        end
        exit(0)
      end

      def action(action_name, args)
        args = args.dup
        ARGV.clear
        if @controller.args.help || !action_name
          self.class.print_help(@controller.args, action_name, self.public_methods.select{|m| self.method(m).owner == self.class })
          exit(0)
        end
        if self.respond_to?(action_name)
          begin
            action = self.method(action_name)
            required_args = action.arity >= 0 ? action.arity : -(action.arity + 1)
            unless required_args <= args.length
              raise ControlError.new("#{action_name} expected at least #{required_args} arguments\nE.g.\n#{action_name} #{action.parameters.map(&:last).map{|x| "[#{x}]"}[-required_args..-1].join(' ')} (options)")
            end
            self.send(action_name, *args)
          rescue ArgumentError => e
            puts e.message
            puts "#{action_name} expects #{required_args} arguments by default\nE.g.\n#{action_name} #{action.parameters.map(&:last).map{|x| "[#{x}]"}[-required_args..-1].join(' ')}"
            self.class.print_help(@controller.args, action_name)
            puts e.backtrace if @controller.verbose?
          rescue ControlError => e
            puts e.message
            puts e.cause
            puts e.cause.backtrace if @controller.verbose?
            self.class.print_help(@controller.args, action_name)
          end
        else
          own_methods = self.public_methods.select{|m| self.method(m).owner == self.class }
          puts "Command not supported: \"#{action_name}\""
          puts "Supported commands are [#{own_methods.join(' ')}]"
          exit(1)
        end
      end

      private
        def read_file(file, label='', help)
          unless file
            raise ControlError.new("Expected #{label} file not given\n#{help}")
          end
          unless File.exists?(file)
            raise ControlError.new("Expected #{label} file #{file} doesnt exist\n#{help}")
          end
          IO.read(file)
        end
    end
  end
end