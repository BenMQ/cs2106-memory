require_relative 'bit_map'
require_relative 'virtual_address'
require_relative 'translation_look_aside_buffer'
require_relative 'page_fault_error'
require_relative 'page_not_exists_error'

class VirtualMemory

  # init_file is the file to initialise the memory
  # use_tlb flags whether to use Translation Look-aside Buffer
  def initialize(init_file, use_tlb)
    @pm = Array.new(1024 * 512, 0)
    @available_frame = BitMap.new(1024)
    @use_tlb = use_tlb
    if use_tlb
      @tlb = TranslationLookAsideBuffer.new
    end

    # Frame 0 is always used by ST
    @available_frame.set_1(0)
    read_init_file init_file
  end

  # Populate the memory with content from a file
  def read_init_file(filename)
    line1 = []
    line2 = []
    File.open(filename, 'r') do |f|
      line1 = f.readline.chomp.split(' ')
      line2 = f.readline.chomp.split(' ')
    end

    # first line is of the format s, f
    (0..(line1.length - 2)).step(2).each do |i|
      s = line1[i].to_i
      f = line1[i + 1].to_i
      @pm[s] = f
    end

    # second line is of the format p, s, f
    (0..(line2.length - 2)).step(3).each do |i|
      p = line2[i].to_i
      s = line2[i + 1].to_i
      f = line2[i + 2].to_i
      @pm[@pm[s] + p] = f
    end
  end

  # Read from a file that includes list of operations
  def operate_on(filename)
    line = []
    results = []
    File.open(filename, 'r') do |f|
      line = f.readline.chomp.split(' ')
    end

    # Each pair of values is in the form of (opcode, address)
    (0..(line.length - 2)).step(2).each do |i|
      op_code = line[i].to_i
      va = VirtualAddress.new(line[i + 1].to_i)
      result = ''
      begin
        if @use_tlb
          tlb_result = @tlb.search(va.s << 10 + va.p)
          if tlb_result > 0
            # print h for cache hit, followed by address
            results.push('h').push(tlb_result + va.w)
            next
          end
        end

        # 0 indicates read, 1 indicates write
        if op_code == 0
          result = read va
        else
          result = write va
        end
        if @use_tlb
          # print m for cache miss
          results.push('m')
        end
        results.push(result)

      rescue PageFaultError => e
        results.push e.message
      rescue PageNotExistsError => e
        results.push e.message
      rescue Exception => e
        results.push 'err'
      end
    end

    @results = results
  end

  # Prints the output into a file in one line
  def write_to(filename)
    target = open(filename, 'w')
    target.truncate(0)
    target.write(@results.join(' '))
    target.write("\n")
    target.close
  end

  # Returns the physical address based on the virtual address,
  # Or throw either page fault or not exist error
  def read(va)
    if @pm[va.s] == -1
      raise PageFaultError, 'pf'
    elsif @pm[va.s] == 0
      raise PageNotExistsError, 'err'
    else
      pt_entry = @pm[va.s] + va.p
    end

    if @pm[pt_entry] == -1
      raise PageFaultError, 'pf'
    elsif @pm[pt_entry] == 0
      raise PageNotExistsError, 'err'
    else
      entry = @pm[pt_entry] + va.w
    end

    if @use_tlb
      # Update the TLB with the result
      @tlb.update(va.s << 10 + va.p, entry)
    end
    entry
  end

  # Returns the physical address based on the virtual address,
  # If page does not exist, create one
  # Throws page fault error
  def write(va)
    if @pm[va.s] == -1
      raise PageFaultError, 'pf'
    elsif @pm[va.s] == 0
      pt_entry = allocate_pt_for(va.s)
    else
      pt_entry = @pm[va.s] + va.p
    end

    if @pm[pt_entry] == -1
      raise PageFaultError, 'pf'
    elsif @pm[pt_entry] == 0
      entry = allocate_page(pt_entry)
    else
      entry = @pm[pt_entry] + va.w
    end

    if @use_tlb
      # Update the TLB with the result
      @tlb.update(va.s << 10 + va.p, entry)
    end
    entry
  end

  # Allocate a new PT for an ST entry
  # entry_address: the address of the ST entry to be updated
  # returns the address for the allocated new page
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
  # returns the address for the allocated new page
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