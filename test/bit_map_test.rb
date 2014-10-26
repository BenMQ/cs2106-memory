require 'test/unit'
require '../bit_map'

class BitMapTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_set_1
    bits = BitMap.new(2*32)
    bits.set_1(0)
    assert_equal(1, bits.bits[0], 'the bit set should become 1')
  end

  def test_set_1_idempotent
    bits = BitMap.new(2*32)
    bits.set_1(3)
    bits.set_1(3)
    assert_equal(1 << 3, bits.bits[0], 'set_1 op should be idempotent')
  end


  def test_set_1_last_bit
    bits = BitMap.new(2*32)
    bits.set_1(31)
    assert_equal(0b10000000000000000000000000000000, bits.bits[0], 'msb should be 1')
  end

  def test_set_1_multiple
    bits = BitMap.new(2*32)
    bits.set_1(1)
    bits.set_1(3)
    assert_equal(0b1010, bits.bits[0], 'each bit should become 1')
  end

  def test_set_1_multiple_words
    bits = BitMap.new(2*32)
    bits.set_1(0)
    bits.set_1(32)
    assert_equal(1, bits.bits[0], 'bit 0 in first word should become 1')
    assert_equal(1, bits.bits[1], 'bit 0 in second word should become 1')
  end

  def test_search_for_0_empty
    bits = BitMap.new(2*32)
    assert_equal(0, bits.search_for_0, 'bit 0 should be empty')
  end

  def test_search_for_0_first_word
    bits = BitMap.new(2*32)
    bits.set_1(0)
    bits.set_1(1)
    bits.set_1(2)
    bits.set_1(4)
    assert_equal(3, bits.search_for_0, 'bit 3 should be empty')
  end
  
  def test_search_for_0_second_word
    bits = BitMap.new(2*32)
    (0..31).each { |i| bits.set_1(i) }

    bits.set_1(32)
    assert_equal(33, bits.search_for_0, 'bit 33 should be empty')
  end

  def test_search_for_00_empty
    bits = BitMap.new(2*32)
    assert_equal(0, bits.search_for_00, 'bit 0 and 1 should be empty')
  end

  def test_search_for_00_first_word
    bits = BitMap.new(2*32)
    bits.set_1(0)
    bits.set_1(1)
    bits.set_1(2)
    bits.set_1(4)
    assert_equal(5, bits.search_for_00, 'bit 5 and 6 should be empty')
  end

  def test_search_for_00_second_word
    bits = BitMap.new(2*32)
    (0..31).each { |i| bits.set_1(i) }

    bits.set_1(32)
    bits.set_1(34)
    assert_equal(35, bits.search_for_00, 'bit 35 and 36 should be empty')
  end


  def test_search_for_00_word_boundary
    bits = BitMap.new(2*32)
    (0..30).each { |i| bits.set_1(i) }

    bits.set_1(33)
    assert_equal(31, bits.search_for_00, 'bit 31 and 32 should be empty')
  end

end