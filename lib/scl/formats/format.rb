module Scl
  class Format
    def output(filename, data)
      IO.write(filename, encode(data))
    end

    def read(filename)
      decode(IO.read(filename))
    end

    def encode(data)
      raise "Must be implemented by subclass"
    end

    def decode(data)
      raise "Must be implemented by subclass"
    end

    def name
      self.class.name
    end
  end
end

require 'scl/formats/base64'
require 'scl/formats/binary'
require 'scl/formats/qrcode'
require 'scl/formats/words'
require 'scl/formats/auto'
require 'scl/formats/hex'

module Scl
  class Format

    BASE64 = Scl::Base64.new
    BINARY = Scl::Binary.new
    WORDS  = Scl::Words.new
    QRCODE = Scl::QRCode.new
    HEX    = Scl::Hex.new
    AUTO   = Scl::Auto.new
  end
end