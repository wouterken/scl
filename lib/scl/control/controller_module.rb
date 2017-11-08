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

      def action(action_name, args)
        args = args.dup
        ARGV.clear
        if self.respond_to?(action_name)
          begin
            action = self.method(action_name)
            required_args = action.arity >= 0 ? action.arity : -(action.arity + 1)
            unless required_args <= args.length
              raise ControlError.new("#{action_name} expected at least #{required_args} arguments\nE.g.\n#{action_name} #{"[arg] " * required_args}")
            end
            self.send(action_name, *args)
          rescue ControlError => e
            puts e.message
            puts e.cause
            puts e.cause.backtrace if self.args.verbose
          end
        else
          puts "Command not supported: \"#{action_name}\""
          exit(1)
        end
      end
    end
  end
end