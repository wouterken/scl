require 'test_helper'
require 'scl'

class FormatsTest < Minitest::Test
  def setup
    @ascii_message  = "This is an ASCII message"
    @binary_message ="\b\x1C\xA3\xA9\x84\x83\xADh{\xD5P\xEB\xD2\x16^\xA2v\xBDi\xD35(=\x1F\x0EDl\xAF\xFDF\tB"
    @base64_message = ::Base64.encode64(@binary_message)
  end

  def test_auto_encode
    assert_equal \
      Scl::Format::AUTO.encode(@ascii_message),
      Scl::Format::BINARY.encode(@ascii_message)

    assert_equal \
      Scl::Format::AUTO.encode(@binary_message),
      Scl::Format::BASE64.encode(@binary_message)

    assert_equal \
      Scl::Format::AUTO.encode(@base64_message),
      Scl::Format::BINARY.encode(@base64_message)
  end

  def test_auto_decode
    assert_equal \
      Scl::Format::AUTO.decode(@ascii_message),@ascii_message

    assert_equal \
      Scl::Format::AUTO.decode(@binary_message),@binary_message

    assert_equal \
      Scl::Format::AUTO.decode(@base64_message),@binary_message
  end

  %w(hex base64 binary words).each do |type|
    define_method("test_#{type}_encode_decode") do
      format = Scl::Format.const_get(type.upcase)
      assert_equal format.decode(format.encode(@ascii_message)), @ascii_message
      assert_equal format.decode(format.encode(@base64_message)), @base64_message
    end
  end
end