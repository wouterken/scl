module Scl
  class AES
    def initialize(block_size=256, cipher_text=:CBC)
      @cipher_text = cipher_text
      @block_size = block_size
    end

    def build_cypher
      OpenSSL::Cipher::AES.new(@block_size, @cipher_text)
    end

    def encrypt(plaintext, key=nil, iv=nil)
      block_cipher = build_cypher
      block_cipher.encrypt
      block_cipher.key = key ||= block_cipher.random_key
      block_cipher.iv  = iv  ||= block_cipher.random_iv
      encrypted_key =
        case
        when rsa.private? then rsa.private_encrypt(key)
        else rsa.public_encrypt(key)
        end
      [block_cipher.update(plaintext) + block_cipher.final, key, iv]
    end

    def decrypt(ciphertext, key, iv)
      block_cipher = build_cypher
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
  end
end