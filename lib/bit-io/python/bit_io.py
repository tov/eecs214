class BitWriter:
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

    def close(self):
        if self.output:
            self.flush()
            self.output.close()
            self.output = None

    def writebit(self, bit):
        if self.nbits == 8:
            self.flush()
        if bit > 0:
            self.bitbuf |= (1 << (7 - self.nbits))
        self.nbits += 1

    def writebits(self, bits, n):
        while n > 0:
            self.writebit(bits & (1 << (n - 1)))
            n -= 1

    def flush(self):
        self.output.write(chr(self.bitbuf))
        self.bitbuf = 0
        self.nbits = 0

class BitReader:
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

    def close(self):
        if self.input:
            self.input.close()
            self.input = None

    def readbit(self):
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
        v = 0
        while n > 0:
            bit = self.readbit()
            if bit == None: return None
            v = (v << 1) | bit
            n -= 1
        return v

