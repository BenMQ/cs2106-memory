class TranslationLookAsideBuffer
  def initialize
    @buffer = Array.new(4)
    # First field is LRU
    # Second field is the sp value
    # Third field is the physical address for the frame start
    @buffer[0] = [0, -1, -1]
    @buffer[1] = [1, -1, -1]
    @buffer[2] = [2, -1, -1]
    @buffer[3] = [3, -1, -1]
  end

  # Look for an entry sp
  # Return the address if sp is found, or -1 otherwise
  def search(sp)
    hit = -1
    @buffer.each_with_index do |line, index|
      if line[1] == sp
        hit = index
        break
      end
    end

    if hit > -1
      @buffer.each do |line|
        # Decrement LRU for those that are greater than the hit entry
        if line[0] > @buffer[hit][0]
          line[0] -= 1
        end
      end
      # set LRU to max
      @buffer[hit][0] = 3
      @buffer[hit][2]
    else
      -1
    end
  end

  # Updates the entry sp with address f
  def update(sp, f)
    @buffer.each do |line|
      if line[0] == 0
        # set LRU to max
        line[0] = 3
        line[1] = sp
        line[2] = f
      else
        # decrement LRU for other fields
        line[0] -= 1
      end
    end
  end

end