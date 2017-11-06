module Scl
  module Control
    class Output
      attr_reader :content
      def initialize(content, suffix)
        @content, @suffix = content, suffix
      end

      def file(path)
        File.join("#{path.gsub(%r(#{@suffix.gsub('.','\.')}$),'')}#{@suffix}")
      end
    end
  end
end