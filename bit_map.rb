class BitMap
  attr_accessor :bits

  # Constructing a bitmap of certain bits
  # Implemented using an array of 32-bit integers
  # The rightmost bit in the bitmap will be the
  # least significant bit in the index 0 of the array
  def initialize(bits)
    @bits = Array.new(bits / 32, 0)
  end

  # Sets a particular bit to 1
  # Rightmost bit being bit 0
  def set_1(bit)
    index = bit / 32
    offset = bit % 32
    @bits[index] = @bits[index] | (1 << offset)
  end

  def set_0(bit)
    # not implemented
  end

  # Return the position of the first 0 bit
  # Starting from the bit position 0
  def search_for_0
    index = 0
    # 2**32 - 1 will mean that the 32-bit sequence full
    while @bits[index] == 2**32 - 1
      index += 1
    end

    offset = 0
    # number >> x & 1 returns the x-th bit
    while @bits[index] >> offset & 1 != 0
      offset += 1
    end

    index * 32 + offset
  end

  # Return the position of two consecutive 0 bits
  def search_for_00
    index = 0
    while index / 32 < @bits.length
      if @bits[index / 32] == 2**32 - 1
        # entire 32-bit sequence is full, skip
        index += 32
      elsif @bits[index / 32] == 2**31
        if @bits[index / 32 + 1] & 1 == 0
          # MSB of the current 32-bit sequence, and LSB of the next 32-bit sequence are 0
          return index + 31
        else
          # skip the entire 32-bit sequence
          index += 32
        end
      elsif @bits[index / 32] >> index % 32 & 0b11 == 0
        # test if bit at position index%32 and the next bit are 0
        return index
      else
        # Not two consecutive 0 bits, move on
        index += 1
      end
    end

    raise 'BitMapFull'

  end

end