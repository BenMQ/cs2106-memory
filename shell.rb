require_relative 'virtual_memory'

# file to initialise memory
init_file = ARGV[0]
# operations to take
op_file = ARGV[1]
# output file
output_file = ARGV[2]
# use 1 to flag for using TLB
use_tlb = ARGV[3] == '1' ? true : false

vm = VirtualMemory.new init_file, use_tlb
vm.operate_on op_file
vm.write_to output_file