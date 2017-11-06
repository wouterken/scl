module SSS
  require 'base64'
  module DH
    # :0> ping        = SSS::DH.ping
    # :1> pong        = SSS::DH.pong(ping[:public])
    # :2> shared_key1 = SSS::DH.done(ping[:private].merge(pong[:public]))[:private][:shared_key]
    # :3> shared_key2 = pong[:private][:shared_key]
    extend self
    def ping(length: 512)
      dh = OpenSSL::PKey::DH.new(length)
      {
        private: {
          der: Base64.encode64(dh.public_key.to_der),
          private_key: dh.priv_key.to_s(16)
        },
        public: {
          der: Base64.encode64(dh.public_key.to_der),
          public_key: dh.pub_key.to_s(16)
        }
      }
    end

    def pong(der:, public_key:)
      dh = OpenSSL::PKey::DH.new(Base64.decode64(der))
      dh.generate_key!
      shared_key = dh.compute_key(OpenSSL::BN.new(public_key, 16))
      {
        private: {
          shared_key: shared_key
        },
        public: {
          public_key: dh.pub_key.to_s(16)
        }
      }
    end

    def done(private_key:, der:, public_key:)
      dh = OpenSSL::PKey::DH.new(Base64.decode64(der))
      dh.priv_key        = OpenSSL::BN.new(private_key, 16)
      shared_key = dh.compute_key(OpenSSL::BN.new(public_key, 16))
      {
        private: {
          shared_key: shared_key
        }
      }
    end
  end
end