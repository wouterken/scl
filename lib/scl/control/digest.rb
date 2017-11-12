module Scl
  module Control
    class Digest < ControllerModule

      help <<-HELP,
      sign. Signs a file using a support hash algorithm. Defaults to sha256
        e.g
          scl digest sign /path/to/file
          scl digest sign /path/to/file -o stdout
          scl digest sign /path/to/file -d sha512
      HELP
      def sign(input_file)
        signature = Scl::Digest.digest(args.digest || 'sha256', read_file(input_file, "File to sign"))
        args.output_file ||= input_file
        args.output_format ||= 'binary'
        controller.output(
          Output.new(signature, ".sig")
        )
      end

      help <<-HELP,
      verify
        e.g.
          scl digest verify file signature
          scl digest verify file signature -d sha512
      HELP
      def verify(input_file, signature_file)
        signature = Scl::Digest.digest(args.digest || 'sha256', read_file(input_file, "File to verify"))
        args.input_format ||= 'binary'
        if signature == input_decoder.decode(read_file(signature_file, "Signature"))
          exit(0)
        else
          exit(1)
        end
      end

      help <<-HELP,
      hmac. Generates an HMAC for a file, can be given an optional key or alternately one will be
      generated for you. Keep hold of this key for verifying signatures in the future
        e.g.
          scl hmac file            # Generates both a digest and a secure random key
          scl hmac file -k keyfile # Generates a digest using an existing key
          scl hmac file -d sha512  # Provide alternate digest algorithm
      HELP
      def hmac(input_file)
        input_key = args.key_path ?
          read_file(args.key_path) :
          nil
        signature, key = Scl::Digest.hmac(args.digest || 'sha256', read_file(input_file, "File to sign"), input_key)
        args.output_file ||= input_file
        args.output_format ||= 'binary'
        controller.output(
          Output.new(signature, ".sig"),
          input_key ? nil : Output.new(key, '.key')
        )
      end

      help <<-HELP,
      hmac. Verifies the contents of a file match an HMAC signature (using a given key)
        e.g.
          scl hmac_verify file signature -k keyfile
      HELP
      def hmac_verify(input_file, signature_file)
        args.input_format ||= 'binary'
        key = input_decoder.decode(read_file(args.key_path, 'HMAC Key file', 'Use -k'))
        data = read_file(input_file, "File to verify")
        signature, key = Scl::Digest.hmac(args.digest || 'sha256', data, key)
        if signature == input_decoder.decode(read_file(signature_file, "Signature"))
          exit(0)
        else
          exit(1)
        end
      end

      help <<-HELP,
      list. List supported hash algorithms
        e.g.
        scl digest list
      HELP
      def list
        puts OpenSSL::Digest.constants.reject{|x| x.to_s =~ /Error/ }
      end

      private
        def ss
          @ss ||= Scl::SecretShare.new(args.min_shares.to_i, args.num_shares.to_i)
        end
    end
  end
end