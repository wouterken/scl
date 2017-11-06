module Scl
  module Control
    class RSA < ControllerModule

      def generate
        begin
          result = Scl::RSA.generate(args.key_size)
          controller.output(
            Output.new(result.public.export, '.pub'),
            Output.new(result.private.export, '.priv')
          )
        rescue StandardError => e
          puts "Couldn't generate key of size #{args.key_size}. Error: "
          puts e.message
        end
      end

      def sign(file)
        unless args.private_key_file
          raise ControlError.new("Please provide a private key file (-Z or --priv) use --help to find out more")
        end
        unless File.exists?(args.private_key_file)
          raise ControlError.new("Private key file #{args.private_key_file} doesnt exist")
        end
        unless File.exists?(file)
          raise ControlError.new("Couldn't find file to sign: #{file}. File doesnt exist")
        end

        private_key = load_key(args.private_key_file)
        signature = private_key.sign(IO.read(file))
        controller.output(
          Output.new(signature, ".sig")
        )
      end

      def verify(file, signature)
        key_file = args.public_key_file || args.private_key_file
        unless key_file
          raise ControlError.new("Please provide a private or public key file (-p --pub-key, -Z or --priv-key) use --help to find out more")
        end
        unless File.exists?(key_file)
          raise ControlError.new("Key file #{key_file} doesnt exist")
        end
        unless File.exists?(file)
          raise ControlError.new("Couldn't find file to verify: #{file}. File doesnt exist")
        end
        unless File.exists?(signature)
          raise ControlError.new("Couldn't find signature to verify: #{signature}. File doesnt exist")
        end
        key = load_key(key_file)
        if key.verify(IO.read(file), input_coder.decode(IO.read(signature)))
          exit(0)
        else
          exit(1)
        end
      end

      def load_key(key_file)
        raw_input     = IO.read(key_file)
        puts "Decoding key using #{input_decoder.name}" if args.verbose
        decoded_input = key_coder.decode(raw_input)
        puts "Constructing new RSA key using decoded input" if args.verbose
        begin
          pkey = OpenSSL::PKey::RSA.new(decoded_input)
          Scl::RSA::Key.new(pkey)
        rescue StandardError => e
          raise ControlError.new("Unable to construct key from decoded input #{e.message}")
        end
      end
    end
  end
end