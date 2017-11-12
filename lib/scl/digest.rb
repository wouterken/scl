module Scl
  class Digest
    def self.digest(digest, data)
      if digest_exists?(digest)
        OpenSSL::Digest.const_get(digest.upcase).new.hexdigest(data)
      end
    end

    def self.hmac(digest, data, key=nil)
      if digest_exists?(digest)
        require 'securerandom'
        key = key || SecureRandom.hex
        [OpenSSL::HMAC.hexdigest(digest, key, data), key]
      end
    end

    private
      def self.digest_exists?(digest)
        begin
          OpenSSL::Digest.const_get(digest.upcase)
        rescue NameError => e
          puts "Couldn't get digest type. #{digest}"
          puts "Try $ scl digest list  – for a list of supported digests"
          return false
        end
        true
      end
  end
end