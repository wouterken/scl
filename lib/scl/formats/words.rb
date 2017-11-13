module Scl
  class Words < Format

    WORDS = IO.read(File.expand_path(__FILE__+"/../wordlist.txt")).split("\n")
    INDICES = Hash[WORDS.map.with_index{|w, i|[w,i]}]

    def encode(data)
      data.bytes.each_slice(2).map do |b1, b2|
        WORDS[(b1 << 8) + (b2 || 0)]
      end.join(' ')
    end

    def decode(data)
      bytes = data.split(' ').each.map do |word|
        bytes = INDICES[word]
        b2 = bytes & 255
        b1 = (bytes >> 8) & 255
        [b1, b2]
      end.flatten
      bytes.map(&:chr).join.gsub(/\x00$/,'')
    end
  end
end