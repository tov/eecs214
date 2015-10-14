package eecs214.bit_io;

import java.io.*;

public final class BitReader implements Closeable {
  private InputStream inner;
  private byte bitBuf = 0;
  private byte nBits = 0;

  public BitReader(InputStream adaptee) {
    inner = adaptee;
  }

  public BitReader(File file) throws FileNotFoundException {
    this(new FileInputStream(file));
  }

  public BitReader(String filename) throws FileNotFoundException {
    this(new FileInputStream(filename));
  }

  @Override
  public void close() throws IOException {
    inner.close();
  }

  public boolean isEof() throws IOException {
    refill();
    return nBits == 0;
  }

  public boolean readBit() throws IOException {
    refill();
    if (nBits == 0) {
      throw new EOFException();
    }

    return (bitBuf >> --nBits & 1) == 1;
  }

  public int readBits(int n) throws IOException {
    int acc = 0;

    for (int i = 0; i < n; ++i) {
      acc = acc << 1 | (readBit() ? 1 : 0);
    }

    return acc;
  }

  private void refill() throws IOException {
    if (nBits == 0) {
      int result = inner.read();

      if (result != -1) {
        bitBuf = (byte) result;
        nBits = 8;
      }
    }
  }
}
