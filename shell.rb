require_relative 'virtual_memory'

init_file = ARGV[0]
op_file = ARGV[1]
output_file = ARGV[2]

vm = VirtualMemory.new init_file
vm.operate_on op_file
vm.write_to output_file