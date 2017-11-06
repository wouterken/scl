module Scl
  module Control
    class DH < ControllerModule
      def action(action_name, args)
        case action_name
        when ''
        else
          puts "Command not supported: \"#{action_name}\""
          exit(1)
        end
      end
    end
  end
end