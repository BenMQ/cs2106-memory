# An encapsulation of a virtual address that
# computes the three components of the address
class VirtualAddress

  attr_accessor :s, :w, :p

  # Components of virtual address
  S_MASK = 0b1111111110000000000000000000
  P_MASK =          0b1111111111000000000
  W_MASK =                    0b111111111


  def initialize(address)
    # bitwise manipulation of each components
    @s = (address & S_MASK) >> 19
    @p = (address & P_MASK) >> 9
    @w = address & W_MASK
  end

end
