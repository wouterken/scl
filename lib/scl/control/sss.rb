module Scl
  module Control
    class SSS < ControllerModule

      help <<-HELP,
      generate. Generate a set of shares for a shared secret
      Arguments are the total number of shares to generate, and the number of shares required to unlock
      the secret.
        e.g
          scl sss generate -m 3 -n 5
          scl sss generate --min-shares=11 --num-shares=14 -o output_file

      Large secrets are encoded using multiple blocks, which can create large shares.
      An alternative more space efficient approach to this is to encode a shorter key using secret sharing,
      and to then encrypt the large secret using this key and a block-cipher

      HELP
      def generate(input_file)
        raise ControlError.new("Min-shares must be a positive integer") unless args.min_shares.to_i > 0
        raise ControlError.new("Num-shares must be a positive integer") unless args.num_shares.to_i > 0
        raise ControlError.new('Num shares must be larger than or equal to min shares') unless args.num_shares.to_i >= args.min_shares.to_i
        input = read_file(input_file)
        args.output_file ||= "secret-shares"
        controller.output(
          Output.new(ss.generate(input).join("\n"), ".txt")
        )
      end

      help <<-HELP,
      combine. Combines a set of shares for a shared secret
      Expects as an argument a file of "\n" separate secret shares
        e.g
          scl sss combine shares.txt
      HELP
      def combine(input_file)
        shares = read_file(input_file).split("\n")
        controller.output(
          Output.new(Scl::SecretShare.combine(shares), ".sec")
        )
      end

      private
        def ss
          @ss ||= Scl::SecretShare.new(args.min_shares.to_i, args.num_shares.to_i)
        end
    end
  end
end