module Scl
  class Scl::Stdout < Scl::Format
    def encode(data)
      puts data
    end

    def decode(data)
      data
    end
  end
end