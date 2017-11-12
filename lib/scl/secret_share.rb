require 'openssl'
require 'ostruct'

module Scl
  PRIME = OpenSSL::BN.new("214663014907494254264734401372860550616125566004826012670437788223410219893687")
  ENCODED_CHUNK_SIZE = 44

  class SecretShare
    def initialize(minimum, shares, encoder: Format::BASE64)
      raise "Minimum must be larger than zero and less than shares" unless (0..shares) === minimum
      @encoder = encoder
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
        polynomial = [chunk] + (@minimum - 1).times.map do |i|
          random
        end
      end

      @shares.times.map do |i|
        result = ''
        poly_result = polynomials.map do |polynomial|
          x = random
          y = evaluate_polynomial(polynomial, x)
          result << base64_encode(x)
          result << base64_encode(y)
        end
        @encoder == Format::BASE64 ? result : @encoder.encode(result)
      end
    end

    def base64_encode(number)
      return ::Base64.urlsafe_encode64(number.to_s(16).rjust(64, ?0).scan(/../).map{|x| x.hex.chr}.join)
    end

    def self.base64_decode(number)
      ::Base64.urlsafe_decode64(number).chars.map{|x| "0#{x.ord.to_s(16)}"[-2..-1] }.join.rjust(64, ?0).hex
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
      x % p
    end

    def self.combine(shares, encoder: nil)
      abs = ->(v){ v < 0 ? v * -1 : v}
      decoded = shares.map do |share|
        share = encoder && encoder != Format::BASE64 ? encoder.decode(share) : share
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
              numerator =  OpenSSL::BN.new((numerator * -current).to_i % PRIME)
              denominator = OpenSSL::BN.new((denominator * (point.x - current)).to_i  % PRIME)
            end
          end
          working = (point.y * numerator) * mod_inverse(denominator) + PRIME
          secret = ((secret + working) + 1000 * PRIME) % PRIME
        end
        secret
      end

      hex_data = chunks.map{|chunk| chunk.to_s(16).rjust(64, "0") }.join
      hex_data.chars.each_slice(64).map(&:join).map do |chunk|
        chunk.gsub(/(?:00)+$/,'').chars.each_slice(2).map{|pair|
          pair.join.to_i(16).chr
        }
      end.join
    end
  end
end