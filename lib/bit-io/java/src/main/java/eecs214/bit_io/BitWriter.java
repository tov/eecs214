package eecs214.bit_io;

import java.io.*;

public final class BitWriter implements Closeable {
  public BitWriter(OutputStream adaptee) {
    inner = adaptee;
  }

  public BitWriter(File file) throws FileNotFoundException {
    this(new FileOutputStream(file));
  }

  public BitWriter(String filename) throws FileNotFoundException {
    this(new FileOutputStream(filename));
  }

  private void writeOut() throws IOException {
    inner.write(bitBuf);
    bitBuf = 0;
    nBits = 0;
  }

  public void writeBit(boolean bit) throws IOException {
    if (bit) {
      bitBuf |= 1 << (7 - nBits);
    }

    if (++nBits == 8) {
      writeOut();
    }
  }

  @Override
  public void close() throws IOException {
    if (nBits > 0) {
      writeOut();
    }

    inner.close();
  }

  private OutputStream inner;
  private byte bitBuf = 0;
  private byte nBits = 0;

  public void writeBits(long b, int n) throws IOException {
    while (--n >= 0) {
      writeBit((b & 1 << n) != 0);
    }
  }
}
