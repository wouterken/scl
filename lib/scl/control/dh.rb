require 'json'
module Scl
  module Control
    class DH < ControllerModule

      help <<-HELP,
      syn. Step 1 of a diffie hellman exchange.
      Generates a private and public key and der to be used to generate a symmetric key with a second party.

        e.g
          >> Using public key (Saves to [filename].enc by default, unless -o is used)
          scl dh syn
          scl dh syn -fbase64
          scl dh syn -o ./dhell
      HELP
      def syn
        syn = dh.syn
        args.output_file ||= "dh-key-exchange"
        controller.output(
          Output.new(syn[:private].to_json, ".dh1.priv"),
          Output.new(syn[:public].to_json, ".dh1.pub")
        )
      end

      help <<-HELP,
      ack. Step 2 of a diffie hellman exchange.
      Requires the public output of step 1 (The der and public key)
      Generates a private and public key and der to be used to generate a symmetric key with a second party.

      The output [output_file].key contains the secret key generated by the DH exchange.
      The public output [output_file].dh2.pub must be passed back to the first party to complete the exchange
        e.g
          >> Using public key (Saves to [filename].enc by default, unless -o is used)
          scl dh ack ./dh-key-exchange.dh1.pub
          scl dh ack ./dhell.dh1.pub -o ./dhell
      HELP
      def ack(file)
        unless File.exists?(file)
          raise ControlError.new("Couldn't find file containing part 1 of diffie hellman exchange: #{file}. File doesnt exist")
        end
        input = JSON.parse(input_decoder.decode(IO.read(file)))
        ack  = dh.ack(der: input['der'], public_key: input['public_key'])
        args.output_file ||= "dh-key-exchange"
        controller.output(
          Output.new(ack[:private].to_json, ".dh2.key"),
          Output.new(ack[:public].to_json, ".dh2.pub")
        )
      end

      help <<-HELP,
      fin. Step 3 and final step of a diffie hellman exchange.
      Requires the private output of step 1 (The der and private key) and the public key from step 2
      Generates a secret key shared with the second party

      The output [output_file].key contains the secret key generated by the DH exchange.

        e.g
          >> Using public key (Saves to [filename].enc by default, unless -o is used)
          scl dh fin ./dh-key-exchange.dh1.priv ./dh-key-exchange.dh2.pub
          scl dh fin ./dhell.dh1.priv ./dhell.dh2.pub -o ./dhell
      HELP
      def fin(dh1_priv, dh2_pub)
        unless File.exists?(dh1_priv)
          raise ControlError.new("Couldn't find file private portion of part 1 of diffie hellman exchange: #{dh1_priv}. File doesnt exist")
        end
        unless File.exists?(dh2_pub)
          raise ControlError.new("Couldn't find file containing public portion of part 2 of diffie hellman exchange: #{dh2_pub}. File doesnt exist")
        end
        dh1 = JSON.parse(input_decoder.decode(IO.read(dh1_priv)))
        dh2 = JSON.parse(input_decoder.decode(IO.read(dh2_pub)))
        result = dh.fin(der: dh1['der'], private_key: dh1['private_key'], public_key: dh2['public_key'])
        args.output_file ||= "dh-key-exchange"
        controller.output(
          Output.new(result[:private].to_json, ".dh1.key")
        )
      end

      private
        def dh
          @dh ||= Scl::DH.new
        end
    end
  end
end