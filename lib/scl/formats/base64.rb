module Scl
  class Scl::Base64 < Scl::Format
    require 'base64'
    def encode(data)
      ::Base64.encode64(data)
    end

    def decode(data)
      ::Base64.decode64(data)
    end
  end
end