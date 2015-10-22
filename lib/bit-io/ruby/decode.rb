#!/usr/bin/env ruby

require './bit_io.rb'

if ARGV.length != 2 then
  STDERR.print("Usage: #{$0} INFILE OUTFILE\n")
  exit 2
end

BitIO::BitReader.open(ARGV[0]) do |input|
  File.open(ARGV[1], 'wb') do |output|
    begin
      loop do
        output.write(input.readbits(7).chr)
      end
    rescue EOFError
      # expected
    end
  end
end
