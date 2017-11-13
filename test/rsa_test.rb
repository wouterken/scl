require 'test_helper'
require 'scl'

class RSATest < Minitest::Test
  def setup
    @key_pair = Scl::RSA.generate(512)
    @message = "Some message"
  end

  def test_can_generate_keypair
    assert @key_pair
    assert_equal @key_pair.class, Scl::RSA
  end

  def test_can_encrypt
    private_key, public_key, ciphertext = Scl::RSA.encrypt(@message)
    assert_equal Scl::RSA::Key.new(OpenSSL::PKey::RSA.new(public_key)).decrypt(ciphertext), @message
  end

  def test_key_can_encrypt
    assert @key_pair.private.encrypt(@message)
    assert @key_pair.public.encrypt(@message)
  end

  def test_key_can_encrypt_large_message
    require 'securerandom'
    large_message = 1000.times.map{ SecureRandom.hex }.join
    assert_equal @key_pair.public.decrypt(
      @key_pair.private.encrypt(large_message)
    ), large_message
  end

  def test_key_can_decrypt
    assert_equal @message, @key_pair.public.decrypt(@key_pair.private.encrypt(@message))
    assert_equal @message, @key_pair.private.decrypt(@key_pair.public.encrypt(@message))
  end

  def test_private_key_can_sign
    assert @key_pair.private.sign(@message)
  end

  def test_private_key_can_verify
    assert @key_pair.private.verify(@key_pair.private.sign(@message), @message)
    assert @key_pair.public.verify(@key_pair.private.sign(@message), @message)
  end

  def test_public_key_cannot_sign
    assert_raises{
     @key_pair.public.sign(@message)
    }
  end

  def test_key_can_export
    assert @key_pair.private.export
    assert @key_pair.private.export.length > 0
    assert Scl::RSA::Key.new(OpenSSL::PKey::RSA.new(@key_pair.private.export))
    assert @key_pair.public.export
    assert @key_pair.public.export.length > 0
    assert Scl::RSA::Key.new(OpenSSL::PKey::RSA.new(@key_pair.public.export))
  end

  def test_can_save_keypair
    path = Dir.mktmpdir
    FileUtils.mkdir_p(path)
    @key_pair.save(path)
    assert File.exist?("#{path}/rsa-keypair.pub")
    assert File.exist?("#{path}/rsa-keypair.priv")
    assert_equal IO.read("#{path}/rsa-keypair.pub"), @key_pair.public.export
    assert_equal IO.read("#{path}/rsa-keypair.priv"), @key_pair.private.export
  end

  def test_fails_on_bad_inputs
    assert_raises{ Scl::RSA::Key.new(OpenSSL::PKey::RSA.new("bad")) }
    assert_raises{ @key_pair.private.decrypt("invalid") }
    assert_raises{ @key_pair.public.decrypt("invalid") }
  end
end