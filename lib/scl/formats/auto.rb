module Scl
  class Scl::Auto < Scl::Format
    def encode(data)
      sorted = (data.chars.map(&:ord).uniq.sort) - [10]
      if sorted.first < 32 || sorted.max > 126
        Scl::Format::BASE64.encode(data)
      else
        Scl::Format::BINARY.encode(data)
      end
    end

    def decode(data)
      png = Regexp.new("\x89PNG".force_encoding("binary"))
      if /^#{png}/ === data
        Scl::Format::QRCODE.decode(data)
      elsif data[/[^A-Za-z0-9\+\/\n=]/]
        Scl::Format::BINARY.decode(data)
      else
        Scl::Format::BASE64.decode(data)
      end
    end
  end
end