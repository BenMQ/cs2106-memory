class VirtualMemory

  def initialize
    @pm = Array.new(1024 * 512, 0)
    @available_frame = BitMap.new(1024)
    # Frame 0 is always used by ST
    @available_frame.set_1(0)
  end

  def read(va)
    if @pm[va.s] == -1
      raise 'PageFault'
    elsif @pm[va.s] == 0
      raise 'PageNotExist'
    else
      pt_entry = @pm[va.s] + va.p
    end

    if @pm[pt_entry] == -1
      raise 'PageFault'
    elsif @pm[pt_entry] == 0
      raise 'PageNotExist'
    else
      entry = @pm[pt_entry] + va.w
    end

    entry
  end

  def write(va)
    if @pm[va.s] == -1
      raise 'PageFault'
    elsif @pm[va.s] == 0
      pt_entry = allocate_pt_for(va.s)
    else
      pt_entry = @pm[va.s] + va.p
    end

    if @pm[pt_entry] == -1
      raise 'PageFault'
    elsif @pm[pt_entry] == 0
      entry = allocate_page(pt_entry)
    else
      entry = @pm[pt_entry] + va.w
    end

    entry
  end

  # Allocate a new PT for an ST entry
  # entry_address: the address of the ST entry to be updated
  def allocate_pt_for(entry_address)
    # find and occupy two consecutive free frames
    free_frame = @available_frame.search_for_00
    @available_frame.set_1(free_frame)
    @available_frame.set_1(free_frame + 1)
    index = free_frame * 512
    # update ST
    @pm[entry_address] = index
    # set the frame contents to be 0
    @pm.fill(0, index, 1024)
    index
  end


  # Allocate a new page for an PT entry
  # entry_address: the address of the PT entry to be updated
  def allocate_page(entry_address)
    free_frame = @available_frame.search_for_0
    @available_frame.set_1(free_frame)
    index = free_frame * 512
    # update PT
    @pm[entry_address] = index
    # set the frame contents to be 0
    @pm.fill(0, index, 512)
    index
  end


end