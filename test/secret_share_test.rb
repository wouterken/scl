require 'test_helper'
require 'scl'

class SSTest < Minitest::Test
  def setup
    @total = 5
    @min = 3
    @message = 'super-secret message'
    @ss = Scl::SecretShare.new(@min, @total)
  end

  def test_it_can_generate_shares
    assert @ss.generate(@message)
  end

  def test_it_generates_the_requested_number
    assert @ss.generate(@message).length, @total
  end

  def test_it_can_combine_shares
    assert_equal Scl::SecretShare.combine(@ss.generate(@message)), @message
  end

  def test_it_can_reconstruct_using_the_minimum
    assert_equal Scl::SecretShare.combine(@ss.generate(@message).sample(@min)), @message
  end

  def test_it_can_reconstruct_using_more_than_the_minimum
    assert_equal Scl::SecretShare.combine(@ss.generate(@message).sample(@min + 1)), @message
  end

  def test_it_can_reconstruct_using_the_total
    assert_equal Scl::SecretShare.combine(@ss.generate(@message).sample(@total)), @message
  end

  def test_it_cannot_reconstruct_using_less_than_minimum
    refute_equal Scl::SecretShare.combine(@ss.generate(@message).sample(@min - 1)), @message
  end

  def test_it_can_generate_using_large_numbers
    min, total = 80, 100
    ss = Scl::SecretShare.new(min, total)
    assert ss.generate(@message)
    assert_equal ss.generate(@message).length, total
  end

  def test_it_can_reconstruct_using_large_numbers
    min, total = 80, 100
    ss = Scl::SecretShare.new(min, total)
    assert_equal @message, Scl::SecretShare.combine(ss.generate(@message).sample(min))
  end

  def test_it_can_support_large_data_using_multiple_chunks
    require 'securerandom'
    large_message = 1000.times.map{ SecureRandom.hex }.join
    min, total = 7, 11
    ss = Scl::SecretShare.new(min, total)
    assert_equal large_message, Scl::SecretShare.combine(ss.generate(large_message).sample(min))
  end

  def test_it_ensures_min_and_total_are_sane
    assert_raises{ Scl::SecretShare.new(5,4) }
    assert_raises{ Scl::SecretShare.new(-3, -1) }
  end
end