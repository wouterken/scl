module Scl
  module Control
    class Controller
      attr_reader :args
      def initialize(args)
        @args = args
        puts "Using output format #{@output_encoder.name}" if args.verbose
        puts "Using input format #{@input_decoder.name}" if args.verbose
      end

      def output_encoder
        coder_for(args.output_format)
      end

      def input_decoder
        coder_for(args.input_format)
      end

      def key_coder
        coder_for(args.key_format)
      end


      def output_file
        "#{@args.output_file}".strip
      end

      def module(module_name)
        case module_name
        when "aes" then Control::AES.new(self)
        when "rsa" then Control::RSA.new(self)
        when "dh"  then Control::DH.new(self)
        when "dh"  then Control::SSS.new(self)
        else
          puts "No module found \"#{module_name}\""
          exit(1)
        end
      end

      def coder_for(format)
        case "#{format}".strip
        when "base64"               then Format::BASE64
        when "qrcode"               then Format::QRCODE
        when "base64"               then Format::BASE64
        when "words"                then Format::WORDS
        when "hex"                  then Format::HEX
        when "binary","text","none" then Format::BINARY
        when "", "auto"             then Format::AUTO
        else
          puts "Unexpected format \"#{format}\""
          exit(1)
        end
      end

      def output(*results)
        case output_file
        when '' then
          puts "\n\n"
          puts results.map{|r| output_encoder.encode(r.content) }.join("\n\n")
        else
          results.each do |result|
            IO.write(
              result.file(output_file),
              output_encoder.encode(result.content)
            ) if confirm_overwrite?(result.file(output_file))
          end
        end
      end

      def confirm_overwrite?(filename)
        if File.exists?(filename)
          puts "File #{filename} already exists. Confirm overwrite? [Yn]"
          if gets.strip.downcase == 'y'
            puts "Confirmed overwrite for #{filename}" if args.verbose
            return true
          else
            puts "Skipping save for #{filename}" if args.verbose
            return false
          end
        end
        return true
      end
    end
  end
end