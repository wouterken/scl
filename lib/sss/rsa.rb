module SSS
  class RSA
    attr_reader :private, :public
    def initialize(file: nil, public: nil, private: nil)
      if file
        @public  = OpenSSL::PKey::RSA.new(IO.read("#{file}.pub")) if File.exists?("#{file}.pub")
        @private = OpenSSL::PKey::RSA.new(IO.read("#{file}.priv")) if File.exists?("#{file}.priv")
      else
        @public  = public
        @private = private
      end
      @public  = Key.new(@public)
      @private = Key.new(@private)
    end

    def save(dir, name='rsa-keypair')
      IO.write(File.join(dir, "#{name}.pub"), @public.export)
      IO.write(File.join(dir, "#{name}.priv"), @private.export)
      dir
    end

    def self.generate
      rsa_pair = OpenSSL::PKey::RSA.new(2048)
      RSA.new(public: rsa_pair.public_key, private: rsa_pair)
    end

    def self.encrypt(msg)
      pair = self.generate
      [pair.private.export, pair.public.export, pair.private.encrypt(msg)]
    end

    class Key
      attr_reader :rsa
      def initialize(rsa)
        @rsa = rsa
      end

      def sign(data)
        rsa.sign(OpenSSL::Digest::SHA256.new, data)
      end

      def verify(signature, data)
        rsa.verify(OpenSSL::Digest::SHA256.new, signature, data)
      end

      def encrypt(plaintext, key=nil, iv=nil)
        block_cipher = OpenSSL::Cipher::AES.new(256, :CBC)
        block_cipher.encrypt
        block_cipher.key = key ||= block_cipher.random_key
        block_cipher.iv  = iv  ||= block_cipher.random_iv
        encrypted_key =
          case
          when rsa.private? then rsa.private_encrypt(key)
          else rsa.public_encrypt(key)
          end
        [encrypted_key, iv, block_cipher.update(plaintext) + block_cipher.final].join('::')
      end

      def decrypt(ciphertext)
        encrypted_key, iv, ciphertext = ciphertext.split('::')
        block_cipher = OpenSSL::Cipher::AES.new(256, :CBC)
        block_cipher.decrypt
        decrypted_key =
          case
          when rsa.private? then rsa.private_decrypt(encrypted_key)
          else rsa.public_decrypt(encrypted_key)
          end
        block_cipher.decrypt
        block_cipher.key = decrypted_key
        block_cipher.iv  =  iv
        block_cipher.update( ciphertext ) + block_cipher.final
      end

      def export
        rsa.export
      end
    end
  end
end