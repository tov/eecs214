module BitIO
  class BitWriter
    def initialize(filename)
      @bitbuf = 0       # INVARIANT 0 .. 255
      @nbits  = 0       # INVARIANT 0 .. 7
      @output = File.open(filename, 'wb')
    end

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

    def writebit(bit)
      @bitbuf |= 1 << (7 - @nbits) if bit
      @nbits += 1
      write_out if @nbits == 8
    end

    def writebits(bits, n)
      while n > 0 do
        writebit(0 != (bits & (1 << (n - 1))))
        n -= 1
      end
    end

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

  class BitReader
    def initialize(filename)
      @bitbuf = 0
      @nbits  = 0
      @input = File.open(filename, 'rb')
    end

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

    def eof?
      @nbits == 0 && @input.eof?
    end

    def readbit
      if @nbits == 0 then
        @bitbuf = @input.readbyte
        @nbits = 8
      end

      @nbits -= 1
      return (@bitbuf >> @nbits) & 1
    end

    def readbits(n)
      v = 0

      while n > 0 do
        bit = readbit
        v = (v << 1) | bit
        n -= 1
      end

      return v
    end

    def close
      if @input then
        @input.close
        @input = nil
      end
    end
  end
end
