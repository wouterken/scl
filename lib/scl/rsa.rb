module Scl
  class RSA
    attr_reader :private, :public
    DELIMITER = "\x0::\x0"

    def initialize(file: nil, public: nil, private: nil, input_encoder: Format::BINARY, output_encoder: Format::BINARY)
      if file
        @public  = OpenSSL::PKey::RSA.new(encoder.decode(IO.read("#{file}.pub"))) if File.exists?("#{file}.pub")
        @private = OpenSSL::PKey::RSA.new(encoder.decode(IO.read("#{file}.priv"))) if File.exists?("#{file}.priv")
      else
        @public  = public
        @private = private
      end
      @output_encoder = output_encoder
      @public  = Key.new(@public)
      @private = Key.new(@private)
    end

    def save(dir, name='rsa-keypair')
      IO.write(File.join(dir, "#{name}.pub"),  @output_encoder.encode(@public.export))
      IO.write(File.join(dir, "#{name}.priv"), @output_encoder.encode(@private.export))
      dir
    end

    def self.generate(key_size=1024)
      rsa_pair = OpenSSL::PKey::RSA.new(key_size || 2048)
      RSA.new(public: rsa_pair.public_key, private: rsa_pair)
    end

    def self.encrypt(msg, key_size=1024)
      pair = self.generate(key_size)
      [pair.private.export, pair.public.export, pair.private.encrypt(msg)]
    end

    class Key
      attr_reader :rsa
      def initialize(rsa)
        @rsa = rsa
        @aes = Scl::AES.new
      end

      def sign(data)
        rsa.sign(OpenSSL::Digest::SHA256.new, data)
      end

      def verify(signature, data)
        rsa.verify(OpenSSL::Digest::SHA256.new, signature, data)
      end

      def encrypt(plaintext, key=nil, iv=nil)
        ciphertext, key, iv = @aes.encrypt(plaintext, key, iv)
        encrypted_key =
          case
          when rsa.private? then rsa.private_encrypt(key)
          else rsa.public_encrypt(key)
          end
        [encrypted_key, iv, ciphertext].join(DELIMITER)
      end

      def decrypt(ciphertext)
        encrypted_key, iv, ciphertext = ciphertext.split(DELIMITER, 3)
        decrypted_key =
          case
          when rsa.private? then rsa.private_decrypt(encrypted_key)
          else rsa.public_decrypt(encrypted_key)
          end
        @aes.decrypt(ciphertext, decrypted_key, iv)
      end

      def export
        rsa.export
      end
    end
  end
end