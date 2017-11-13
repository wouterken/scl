module Scl
  module Control
    class AES < ControllerModule

      help <<-HELP,
      encrypt. Encrypt a given file.
      Can optionally be given an existing key, otherwise a unique one will be generated alongside
      the cipher text.
        e.g
          scl aes encrypt somefile
          scl aes encrypt somefile -k somekey
      HELP
      def encrypt(file)
        input_key = args.key_path ?
          read_file(args.key_path) :
          nil
        file_content = read_file(file)
        ct, key, iv = aes.encrypt(file_content, input_key)
        args.output_file ||= file
        controller.output(
          Output.new(iv << '::' << ct, ".enc"),
          input_key ? nil : Output.new(key, '.key')
        )
      end


      help <<-HELP,
      decrypt. Decrypt a given file.
      Must be given a key using -k/--key-path
        e.g
          scl aes decrypt somefile.enc -k somekey.key
          scl aes decrypt somefile.enc -k somekey.key -o output.txt
      HELP
      def decrypt(file)
        key = input_decoder.decode(read_file(args.key_path, "encryption key", "Use -k option"))
        iv, cipher_text = input_decoder.decode(read_file(file, 'ciphertext')).split('::', 2)

        plaintext = aes.decrypt(cipher_text, key, iv)
        args.output_format = 'binary'
        controller.output(
          Output.new(plaintext, '')
        )
      end

      help <<-HELP,
      ciphers. Prints a list of supported ciphers

        e.g
          scl aes ciphers
      HELP
      def ciphers
        puts OpenSSL::Cipher.ciphers.select{|x| x[/^aes/]}
      end

      private
        def aes
          Scl::AES.new(args.block_size, args.block_cipher)
        end
    end
  end
end