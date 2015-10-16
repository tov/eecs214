"""
Classes for reading and writing files as streams of individual bits
(rather than bytes).
"""

class BitReader(object):
    """
    For reading from an input file one bit (or more) at a time.

    Args:
        filename (str): the file to open for reading

    Example:
        reader = BitReader(file_to_read)
    """

    def close(self):
        """
        Closes a `BitReader`, returning its resources to the system.

        Example:
            bitreader.close()
        """

        if self.input:
            self.input.close()
            self.input = None

    def readbit(self):
        """
        Reads a single bit from a `BitReader`.

        Returns:
            0, 1, or None for end-of-file

        Example:
            bit = reader.readbit()
            if (bit == None):
                # eof or read error
            else:
                # bit is 0 or 1
        """

        if self.nbits == 0:
            a = self.input.read(1)
            if len(a) > 0:
                self.bitbuf = ord(a)
                self.nbits = 8
            else:
                return None

        self.nbits -= 1
        return (self.bitbuf >> self.nbits) & 1

    def readbits(self, n):
        """
        Reads the next `n` bits from a `BitReader`, and returns them
        interpreted as a big-endian `n`-bit integer.

        Args:
            n (int): the number of bits to read

        Returns:
            An integer, or None for end-of-file

        Example:
            # Read the next 8 bits as two 4-bit numbers. For example, if
            # the next 8 bits are 01001010, then `nibble1` will be 4
            # (from 0100) and `nibble2` will be 10 (from 1010).
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

    def __init__(self, filename):
        self.bitbuf = 0
        self.nbits = 0
        self.input = open(filename, 'rb')

    def __del__(self):
        self.close()

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()

class BitWriter(object):
    """
    For writing to an output file one bit (or more) at a time.

    Args:
        filename (str): the file to open (or create) for writing

    Example:
        reader = BitWriter(file_to_write)
    """

    def close(self):
        """
        Closes a `BitWriter`, flushing any remaining bits to the file
        and returning its resources to the system. Because files store
        bits in octets (8-bit bytes), the last byte may need to be
        padded with 0s.

        Example:
            bitwriter.close()
        """
        if self.output:
            self._flush()
            self.output.close()
            self.output = None

    def writebit(self, bit):
        """
        Writes a single bit to a `BitWriter`.

        Example:
            writer.writebit(1)  // writes a 1
            writer.writebit(0)  // writes a 0
        """

        if self.nbits == 8:
            self._flush()
        if bit > 0:
            self.bitbuf |= (1 << (7 - self.nbits))
        self.nbits += 1

    def writebits(self, bits, n):
        """
        Writes integer `bits` to a `BitWriter`, represented as an
        `n`-bit big-endian integer.

        Args:
            bits (int): the value to write
            n (int): the number of bits to write

        Example:
            writer.writebits(22, 5)     # writes 10110
        """

        while n > 0:
            self.writebit(bits & (1 << (n - 1)))
            n -= 1

    def _flush(self):
        self.output.write(chr(self.bitbuf))
        self.bitbuf = 0
        self.nbits = 0

    def __init__(self, filename):
        self.bitbuf = 0
        self.nbits = 0
        self.output = open(filename, 'wb')

    def __del__(self):
        self.close()

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()

