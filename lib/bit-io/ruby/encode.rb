#!/usr/bin/env ruby

require './bit_io.rb'

if ARGV.length != 2 then
  STDERR.print("Usage: #{$0} INFILE OUTFILE\n")
  exit 2
end

File.open(ARGV[0], 'r') do |input|
  BitIO::BitWriter.open(ARGV[1]) do |output|
    until input.eof? do
      output.writebits(input.readbyte, 7)
    end
  end
end
