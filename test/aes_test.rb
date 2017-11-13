require 'test_helper'
require 'scl'

class AesTest < Minitest::Test
  def setup
    @aes = Scl::AES.new
    @secret = "A super secret message"
  end

  def test_can_encrypt
    assert @aes.encrypt(@secret)
  end

  def test_accepts_an_optional_key
    optional_key = "an optional key of sufficient length"
    cipher, key, iv =  @aes.encrypt(@secret, optional_key)
    plaintext = @aes.decrypt(cipher, key, iv)
    assert_equal plaintext, @secret
    assert_equal key, optional_key
  end

  def test_accepts_an_optional_iv
    optional_key = "an optional key of sufficient length"
    optional_iv  = "an optional iv of sufficient length"
    cipher, key, iv =  @aes.encrypt(@secret, optional_key, optional_iv)
    plaintext = @aes.decrypt(cipher, key, iv)
    assert_equal plaintext, @secret
    assert_equal key, optional_key
    assert_equal iv, optional_iv
  end

  def test_can_decrypt
    cipher, key, iv = @aes.encrypt(@secret)
    plaintext = @aes.decrypt(cipher, key, iv)
    assert_equal plaintext, @secret
  end

  def test_can_use_alternate_ciphers
    aes512 = Scl::AES.new(128)
    cipher, key, iv = aes512.encrypt(@secret)
    plaintext = aes512.decrypt(cipher, key, iv)
    assert_equal plaintext, @secret
  end

  def test_fails_unsupported_ciphers
    aes512 = Scl::AES.new(512)
    assert_raises{
      aes512.encrypt(@secret)
    }
  end

  def test_decrypt_will_fail
    assert_raises{
      @aes.decrypt('bad decrypt', 'bad key', 'bad iv')
    }
  end

  def test_encrypt_fail_on_bad_key
    assert_raises{
      @aes.encrypt("something", '')
    }
  end
end