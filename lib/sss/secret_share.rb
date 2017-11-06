require 'openssl'
require 'ostruct'

module SSS
  # PRIME              = OpenSSL::BN.new("12444564549162300069543775116623647877224518987958124815625997062953405635547036772213547239478998264319051058804208632790257230105943289608172167621038647")
  PRIME = OpenSSL::BN.new("115792089237316195423570985008687907853269984665640564039457584007913129639747")

  ENCODED_CHUNK_SIZE = 175
  class SecretShare
    def initialize(minimum, shares)
      raise "Minimum must be larger than zero and less than shares" unless (0..shares) === minimum
      @minimum = minimum
      @shares  = shares
    end

    def random()
      @seen ||= { nil => true}
      number = Random.rand(1...PRIME) while @seen[number]
      @seen[number] = true
      OpenSSL::BN.new(number)
    end

    def chunks(secret)
      Enumerator.new do |enum|
        as_hex = secret.each_byte.map{|b| b.to_s(16).rjust(2, '0') }.join
        as_hex.chars.each_slice(64) do |slice|
          chunk = OpenSSL::BN.new(slice.join.ljust(64, ?0), 16)
          enum << chunk
        end
      end
    end

    def evaluate_polynomial(polynomial, x)
      polynomial.reverse.reduce(OpenSSL::BN.new(0)) do |mem, value|
        ((mem * x) % PRIME + value) % PRIME
      end
    end

    def generate(secret)
      polynomials = chunks(secret).map do |chunk|
        polynomial = [chunk] + @minimum.times.map do |i|
          random
        end
      end

      @shares.times.map do |i|
        result = ''
        poly_result = polynomials.map do |polynomial|
          x = random
          y = evaluate_polynomial(polynomial, x)
          result << base64_encode(x.to_s(16))
          result << base64_encode(y.to_s(16))
        end
        result
      end
    end

    def base64_encode(x)
      return Base64.encode64(x.rjust(64,'0'))
    end

    def self.base64_decode(x)
      OpenSSL::BN.new(Base64.decode64(x).gsub(/^0+/,''), 16)
    end

    def self.extended_gcd(a, b)
      abs = ->(v){ v < 0 ? v * -1 : v}
      last_remainder, remainder = abs[a], abs[b]
      x, last_x, y, last_y = 0, 1, 1, 0
      while remainder != 0
        last_remainder, (quotient, remainder) = remainder, last_remainder./(remainder)
        x, last_x = last_x - quotient*x, x
        y, last_y = last_y - quotient*y, y
      end

      return last_remainder, last_x * (a < 0 ? -1 : 1)
    end

    def self.mod_inverse(e, p=PRIME)
      g, x = extended_gcd(e, p)
      if g != 1
        raise "Couldnt mod_inverse #{e}"
      end
      x % p
    end

    def self.combine(shares)
      abs = ->(v){ v < 0 ? v * -1 : v}
      decoded = shares.map do |share|
        share.chars.each_slice(ENCODED_CHUNK_SIZE).map(&:join).each_slice(2).map do |random, polynomial|
          OpenStruct.new({
            x: base64_decode(random),
            y: base64_decode(polynomial)
          })
        end
      end

      chunks = decoded[0].length.times.map do |chunk|
        secret = OpenSSL::BN.new(0)
        decoded.each do |share|
          point = share[chunk]
          numerator, denominator = OpenSSL::BN.new(1), OpenSSL::BN.new(1)
          decoded.each do |peer|
            if peer != share
              current = peer[chunk].x
              negative = OpenSSL::BN.new(-1) * current
              added = point.x - current
              numerator = ((numerator * negative) % PRIME)
              denominator = (denominator * added) % PRIME
            end
          end
          working = (point.y * numerator) * mod_inverse(denominator)
          secret = (secret + working) % PRIME
        end
        secret
      end

      hex_data = ""
      chunks.each do |chunk|
        hex_data << chunk.to_s(16).rjust(64, "0")
      end
      hex_data.chars.each_slice(64).map(&:join).map do |chunk|
        chunk.gsub(/(?:00)+$/,'').chars.each_slice(2).map{|pair|
          begin
            pair.join.to_i(16).chr
          rescue
            binding.pry
          end
      }
      end.join
    end
  end
end