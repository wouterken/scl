module Scl
  module Control
    class RSA < ControllerModule

      help <<-HELP,
      Generates an RSA keypair
        e.g
          >> Generates a key-pair and prints to stdout
          $ scl rsa generate

          >> Generates a key-pair and saves to the filesystem
          $ scl rsa generate -o /path/to/file
      HELP
      def generate
        begin
          result = Scl::RSA.generate(args.key_size)
          controller.output(
            Output.new(result.public.export, '.pub'),
            Output.new(result.private.export, '.priv')
          )
        rescue StandardError => e
          raise ControlError.new("Couldn't generate key of size #{args.key_size}")
        end
      end

      help <<-HELP,
      Signs a file using an RSA private key.
      This file can then be verified using the corresponding public-key or the same private-key
        e.g
          >> Sign [file] using private key
          $ scl rsa sign file -Z /path/to/private/key
      HELP
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
        args.output_file ||= file
        controller.output(
          Output.new(signature, ".sig")
        )
      end

      help <<-HELP,
      Verifies a file matches a signature for an RSA private key
      Verification can be performed using the corresponding public-key or the same private-key that generated the signature
        e.g

          >> Verify [file] using public key
          $ scl rsa verify -p /path/to/private/key file file.sig
          $ scl rsa verify --pub-key /path/to/private/key file file.sig

          >> Verify [file] using private key
          $ scl rsa verify -Z /path/to/private/key file file.sig
      HELP
      def verify(file, signature="#{file}.sig")
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
        if key.verify(input_decoder.decode(IO.read(signature)), IO.read(file))
          exit(0)
        else
          exit(1)
        end
      end

      help <<-HELP,
      Encrypts a file.
        e.g
          >> Using public key (Saves to [filename].enc by default, unless -o is used)
          scl rsa encrypt -p /path/to/public_key /path/to/file
          scl rsa encrypt --pub-key /path/to/public_key /path/to/file

          >> Using public key (Saves to [filename].enc by default, unless -o is used)
          scl rsa encrypt -Z /path/to/private_key /path/to/file
          scl rsa encrypt --priv-key /path/to/private_key /path/to/file
      HELP
      def encrypt(file)
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
        key = load_key(key_file)
        encrypted = key.encrypt(IO.read(file))
        args.output_file ||= file
        controller.output(
          Output.new(encrypted, '.enc')
        )
      end

      help <<-HELP,
      Decrypts a file.
        e.g
          >> Using public key (Writes to stdout unless -o is used)
          scl rsa decrypt -p /path/to/public_key /path/to/file.enc
          scl rsa decrypt --pub-key /path/to/public_key /path/to/file.enc

          >> Using public key (Writes to stdout unless -o is used)
          scl rsa decrypt -Z /path/to/private_key /path/to/file.enc
          scl rsa decrypt --priv-key /path/to/private_key /path/to/file.enc
      HELP
      def decrypt(file)
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
        key = load_key(key_file)
        decrypted = key.decrypt(input_decoder.decode(IO.read(file)))
        args.output_format = 'binary'
        controller.output(
          Output.new(decrypted, '')
        )
      end

      private
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