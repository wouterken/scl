require 'test_helper'
require 'scl'

class DigestTest < Minitest::Test
  def setup
  end

  def test_can_generate_digest
    assert Scl::Digest.digest("sha256", "Some data to hash")
  end

  def test_can_generate_hmac
    assert Scl::Digest.hmac("sha256", "Some data to hash")
  end

  def test_hmac_uses_key
    in_key = "some predetermined key value"
    digest, key = Scl::Digest.hmac("sha256", "Some data to hash", in_key)
    assert_equal in_key, key
    assert_equal \
      Scl::Digest.hmac("sha256", "Some data to hash", key),
      Scl::Digest.hmac("sha256", "Some data to hash", key)
  end

  def test_hmac_generates_key
    digest, key = Scl::Digest.hmac("sha256", "Some data to hash")
    assert digest
    assert key
  end

  def test_skips_invalid_digest_type
    refute Scl::Digest.digest("bad hash", "Some data to hash")
  end
end