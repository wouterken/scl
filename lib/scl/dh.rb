module Scl
  require 'base64'
  class DH
    attr_reader :encoder

    def initialize(encoder: Format::BASE64)
      @encoder = encoder
    end
    # :0> syn        = Scl::DH.new.syn
    # :1> ack        = Scl::DH.new.ack(syn[:public])
    # :2> shared_key1 = Scl::DH.new.fin(syn[:private].merge(ack[:public]))[:private][:shared_key]
    # :3> shared_key2 = ack[:private][:shared_key]
    def syn(length: 512)
      dh = OpenSSL::PKey::DH.new(length)
      {
        private: {
          der:         encoder.encode(dh.public_key.to_der),
          private_key: encoder.encode(dh.priv_key.to_s(16))
        },
        public: {
          der:        encoder.encode(dh.public_key.to_der),
          public_key: encoder.encode(dh.pub_key.to_s(16))
        }
      }
    end

    def ack(der:, public_key:)
      dh = OpenSSL::PKey::DH.new(encoder.decode(der))
      dh.generate_key!
      shared_key = dh.compute_key(OpenSSL::BN.new(encoder.decode(public_key), 16))
      {
        private: {
          shared_key: encoder.encode(shared_key)
        },
        public: {
          public_key: encoder.encode(dh.pub_key.to_s(16))
        }
      }
    end

    def fin(private_key:, der:, public_key:)
      dh = OpenSSL::PKey::DH.new(encoder.decode(der))
      dh.priv_key        = OpenSSL::BN.new(encoder.decode(private_key), 16)
      shared_key = dh.compute_key(OpenSSL::BN.new(encoder.decode(public_key), 16))
      {
        private: {
          shared_key: encoder.encode(shared_key)
        }
      }
    end
  end
end