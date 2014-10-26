class VirtualMemory

  def initialize
    @pm = Array.new(1024 * 512)
    @available_frame = Array.new(32, 0)
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

  end


end