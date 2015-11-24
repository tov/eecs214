# Classes for reading and writing files as streams of individual bits
# (rather than bytes):
#
# [BitIO::BitReader] For reading one bit at a time
# [BitIO::BitWriter] For writing one bit at a time
module BitIO
  # For writing to an output file one bit (or more) at a time.
  class BitWriter
    # Opens a new +BitWriter+ to write to the given file.
    #
    # === Parameters:
    #
    # [+filename+ : +String+] the file to open for writing
    #
    # === Example:
    #
    # Open a file named +file_to_write+ for writing:
    #
    #     writer = BitWriter.new(file_to_write)
    #
    def initialize(filename)
      @bitbuf = 0       # INVARIANT 0 .. 255
      @nbits  = 0       # INVARIANT 0 .. 7
      @output = File.open(filename, 'wb')
    end

    # Opens a new +BitWriter+ to write to the given file. If given a
    # block, the writer is passed to the block and closed when the block
    # returns.
    #
    # === Parameters:
    #
    # [+filename+ : +String+] the file to open for writing
    #
    # === Returns:
    #
    # - the result of the block if given a block
    # - the new writer if not given a block
    #
    # === Example:
    #
    # Open a file named +file_to_write+ for reading:
    #
    #     BitWriter.open(file_to_write) { |writer|
    #         writer.writebit(1)
    #     }
    #
    def self.open(filename)
      writer = self.new(filename)

      if block_given? then
        begin
          yield writer
        ensure
          writer.close
        end
      else
        writer
      end
    end

    # Writes a single bit to a +BitWriter+.
    #
    # === Parameters:
    #
    # [+bit+ : +Boolean+] true for 1, false for 0
    #
    # === Example:
    #
    # Write the 7-bit ASCII representation of +'A'+:
    #
    #     writer.writebit(true)
    #     writer.writebit(false)
    #     writer.writebit(false)
    #     writer.writebit(false)
    #     writer.writebit(false)
    #     writer.writebit(false)
    #     writer.writebit(true)
    def writebit(bit)
      @bitbuf |= 1 << (7 - @nbits) if bit
      @nbits += 1
      write_out if @nbits == 8
    end


    # Writes integer +bits+ to a +BitWriter+, represented as an
    # +n+-bit big-endian integer.
    #
    # === Parameters:
    #
    # [+bits+ : +Integer+] the value to write
    # [+n+ : +Integer+] the number of bits to write
    #
    # === Example:
    #
    # Write the bits +10110+ (21 in decimal):
    #
    #     writer.writebits(21, 5)
    #
    # Write the bits +0010110+ (also 21 in decimal):
    #
    #     writer.writebits(21, 7)
    #
    def writebits(bits, n)
      while n > 0 do
        writebit(0 != (bits & (1 << (n - 1))))
        n -= 1
      end
    end

    # Closes a +BitWriter+, flushing any remaining bits to the file
    # and returning its resources to the system. Because files store
    # bits in octets (8-bit bytes), the last byte will be automatically
    # padded with 0s if necessary.
    #
    # === Example:
    #
    # Close a bit writer when we are finished with it:
    #
    #     writer.close
    #
    def close
      if @output then
        write_out
        @output.close
        @output = nil
      end
    end

    private

    def write_out
        @output.write(@bitbuf.chr)
        @bitbuf = 0
        @nbits = 0
    end
  end

  # For reading from an input file one bit (or more) at a time.
  class BitReader
    # Opens a new +BitReader+ to read from the given file.
    #
    # === Parameters:
    #
    # [+filename+ : +String+] the file to open for reading
    #
    # === Example:
    #
    # Open a file named +file_to_read+ for reading:
    #
    #     reader = BitReader.new(file_to_read)
    #
    def initialize(filename)
      @bitbuf = 0
      @nbits  = 0
      @input = File.open(filename, 'rb')
    end

    # Opens a new +BitReader+ to read from the given file. If given a
    # block, the reader is passed to the block and closed when the block
    # returns.
    #
    # === Parameters:
    #
    # [+filename+ : +String+] the file to open for reading
    #
    # === Returns:
    #
    # - the result of the block if given a block
    # - the new reader if not given a block
    #
    # === Example:
    #
    # Open a file named +file_to_read+ for reading:
    #
    #     BitWriter.open(file_to_read) { |reader|
    #         reader.readbit
    #     }
    #
    def self.open(filename)
      result = self.new(filename)

      if block_given? then
        begin
          yield result
        ensure
          result.close
        end
      else
        result
      end
    end

    # Determines when the end of file has been reached.
    #
    # === Returns:
    #
    # +false+ if EOF has not been encountered yet, or +true+ if a read
    # has failed due to EOF
    #
    # === Example:
    #
    # while not reader.eof?  do
    #   bit = reader.readbit
    #   //
    # end
    def eof?
      @nbits == 0 && @input.eof?
    end

    #   Reads a single bit from a +BitReader+.
    #
    #   === Returns:
    #
    #   +0+, +1+, or +nil+ for end-of-file
    #
    #   === Example:
    #
    #   Read a bit from a reader:
    #
    #       bit = reader.readbit
    #
    def readbit
      if @nbits == 0 then
        @bitbuf = @input.readbyte
        @nbits = 8
      end

      @nbits -= 1
      return (@bitbuf >> @nbits) & 1
    end

    # Reads +n+ bits from a +BitReader+ and returns them interpreted
    # as an +n+-bit big-endian integer.
    #
    # === Parameters:
    #
    # [+n+ (+Integer+)] The number of bits to read
    #
    # === Returns:
    #
    # The integer that was read
    #
    # === Example:
    #
    # Read the next 8 bits as two 4-bit numbers; for example, if the
    # next 8 bits are `01001010`, then `nibble1` will be `4` (from
    # `0100`) and `nibble2` will be `10` (from `1010`):
    #
    #     nibble1 = reader.readbits(4)
    #     nibble2 = reader.readbits(4)
    #
    def readbits(n)
      v = 0

      while n > 0 do
        bit = readbit
        v = (v << 1) | bit
        n -= 1
      end

      return v
    end

    # Closes the input file, returning its resources to the system.
    #
    # === Example:
    #
    # Close a bit reader when we no longer need it:
    #
    #     reader.close
    #
    def close
      if @input then
        @input.close
        @input = nil
      end
    end
  end
end

