require 'test_helper'
require 'scl'
require 'pry-byebug'

class DHTest < Minitest::Test
  def setup
    @dh    = Scl::DH.new
    @dhhex = Scl::DH.new(encoder: Scl::Format::HEX)
  end

  def test_generates_syn
    assert @dh.syn
  end

  def test_syn_has_public_and_private_parts
    syn = @dh.syn
    assert_includes syn, :private
    assert_includes syn, :public
    assert_equal syn.size, 2
    syn.each do |key, part|
      assert_includes part, :der
      assert_includes part, :"#{key}_key"
    end
  end

  def test_syn_is_encoded
    assert @dhhex.syn[:private][:der][/^[a-f0-9]+$/]
    refute @dh.syn[:private][:der][/[^A-Za-z0-9\+\/\n=]/]
    assert @dhhex.syn[:public][:der][/^[a-f0-9]+$/]
    refute @dh.syn[:public][:der][/[^A-Za-z0-9\+\/\n=]/]
  end

  def test_valid_ack_for_syn
    syn = @dh.syn
    ack = @dh.ack(syn[:public])
    assert ack
  end

  def test_invalid_ack_for_syn
    assert_raises{
      @dh.ack(der: 'bad', public_key: 'syn')
    }
  end

  def test_ack_is_encoded
    syn = @dh.syn
    ack = @dh.ack(syn[:public])
    synhex = @dhhex.syn
    ackhex = @dhhex.ack(synhex[:public])
    refute ack[:public][:public_key][/[^A-Za-z0-9\+\/\n=]/]
    assert ackhex[:public][:public_key][/^[a-f0-9]+$/]
  end

  def test_ack_contains_key
    syn = @dh.syn
    ack = @dh.ack(syn[:public])
    assert_includes ack[:private], :shared_key
  end

  def test_fin_generates_identical_key
    syn = @dh.syn
    ack = @dh.ack(syn[:public])
    fin = @dh.fin(syn[:private].merge(ack[:public]))
    assert_equal fin[:private][:shared_key], ack[:private][:shared_key]
  end

  def test_fin_is_encoded
    syn = @dh.syn
    ack = @dh.ack(syn[:public])
    fin = @dh.fin(syn[:private].merge(ack[:public]))
    refute fin[:private][:shared_key][/[^A-Za-z0-9\+\/\n=]/]

    synhex = @dhhex.syn
    ackhex = @dhhex.ack(synhex[:public])
    finhex = @dhhex.fin(synhex[:private].merge(ackhex[:public]))
    assert finhex[:private][:shared_key][/^[a-f0-9]+$/]
  end
end