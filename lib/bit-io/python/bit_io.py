"""
Classes for reading and writing files as streams of individual bits
(rather than bytes).
"""

class BitReader(object):
    """For reading from an input file one bit (or more) at a time."""

    __slots__ = ['_bitbuf', '_nbits', '_input']

    def __init__(self, filename):
        """
        Opens a new `BitReader` to read from the given file.

        **Parameters:**

          - `filename` (`str`): the file to open for reading

        **Example:**

        Open a file named `file_to_read` for reading:

            reader = BitReader(file_to_read)
        """

        self._bitbuf = 0
        self._nbits = 0
        self._input = open(filename, 'rb')


    def close(self):
        """
        Closes a `BitReader`, returning its resources to the system.

        **Example:**

        Close a reader when we're done with it:

            reader.close()
        """

        if self._input:
            self._input.close()
            self._input = None

    def readbit(self):
        """
        Reads a single bit from a `BitReader`.

        **Returns:**

        `0`, `1`, or `None` for end-of-file

        **Example:**

        Read a bit from a reader, and then check whether it succeeded or
        reached end-of-file:

            bit = reader.readbit()
            if bit == None:
                # eof or read error
            else:
                # bit is 0 or 1
        """

        if self._nbits == 0:
            a = self._input.read(1)
            if len(a) > 0:
                self._bitbuf = ord(a)
                self._nbits = 8
            else:
                return None

        self._nbits -= 1
        return (self._bitbuf >> self._nbits) & 1

    def readbits(self, n):
        """
        Reads the next `n` bits from a `BitReader`, and returns them
        interpreted as a big-endian `n`-bit integer.

        **Parameters:**

          - `n` (`int`): the number of bits to read

        **Returns:**

        An integer, or `None` for end-of-file

        **Example:**

        Read the next 8 bits as two 4-bit numbers; for example, if the
        next 8 bits are `01001010`, then `nibble1` will be `4` (from
        `0100`) and `nibble2` will be `10` (from `1010`):

            nibble1 = reader.readbits(4)
            nibble2 = reader.readbits(4)
        """

        v = 0
        while n > 0:
            bit = self.readbit()
            if bit == None: return None
            v = (v << 1) | bit
            n -= 1
        return v

    def __del__(self):
        self.close()

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()

class BitWriter(object):
    """For writing to an output file one bit (or more) at a time."""

    __slots__ = ['_bitbuf', '_nbits', '_output']

    def __init__(self, filename):
        """
        Opens a new `BitWriter` to write to the given file.

        **Parameters:**

          - `filename` (`str`): the file to open (or create) for writing

        **Example:**

        Open a file named `file_to_write` for writing:

            writer = BitWriter(file_to_write)
        """

        self._bitbuf = 0
        self._nbits = 0
        self._output = open(filename, 'wb')

    def close(self):
        """
        Closes a `BitWriter`, flushing any remaining bits to the file
        and returning its resources to the system. Because files store
        bits in octets (8-bit bytes), the last byte will be
        automatically padded with 0s if necessary.

        **Example:**

        Close a bit writer when we are finished with it:

            bitwriter.close()
        """
        if self._output:
            self._flush()
            self._output.close()
            self._output = None

    def writebit(self, bit):
        """
        Writes a single bit to a `BitWriter`.

        **Example:**

        Write the 7 bits in the ASCII representation of the letter 'A':

            writer.writebit(1)
            writer.writebit(0)
            writer.writebit(0)
            writer.writebit(0)
            writer.writebit(0)
            writer.writebit(0)
            writer.writebit(1)
        """

        if self._nbits == 8:
            self._flush()
        if bit > 0:
            self._bitbuf |= (1 << (7 - self._nbits))
        self._nbits += 1

    def writebits(self, bits, n):
        """
        Writes integer `bits` to a `BitWriter`, represented as an
        `n`-bit big-endian integer.

        **Parameters:**

          - `bits` (`int`): the value to write
          - `n` (`int`): the number of bits to write

        **Example:**

        Write the bits `10110` (22 in binary):

            writer.writebits(22, 5)

        Write the bits `0010110` (also 22 in binary):

            writer.writebits(22, 7)
        """

        while n > 0:
            self.writebit(bits & (1 << (n - 1)))
            n -= 1

    def _flush(self):
        self._output.write(chr(self._bitbuf))
        self._bitbuf = 0
        self._nbits = 0

    def __del__(self):
        self.close()

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()

