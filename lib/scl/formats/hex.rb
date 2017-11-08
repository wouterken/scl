module Scl
  class Scl::Hex < Scl::Format
    def encode(data)
      data.bytes.map{|x| x.to_s(16).rjust(2, ?0) }.join
    end

    def decode(data)
      data.scan(/../).map{|s| s.to_i(16) }.map(&:chr).join
    end
  end
end