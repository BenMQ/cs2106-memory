#!/usr/bin/env ruby
require_relative 'virtual_memory'
require 'optparse'

options = {}

optparse = OptionParser.new do|opts|
  opts.banner = 'Usage: shell.rb [options] init_file op_file output_file'

  options[:buffer] = false
  opts.on('-b', '--buffer', 'Enable Translation Lookaside Buffer') do
    options[:buffer] = true
  end
end

# Parse flags
optparse.parse!

# file to initialise memory
init_file = ARGV[0]
# operations to take
op_file = ARGV[1]
# output file
output_file = ARGV[2]

if ARGV.length < 3
  puts optparse.help
else
  vm = VirtualMemory.new init_file, options[:buffer]
  vm.operate_on op_file
  vm.write_to output_file
end
