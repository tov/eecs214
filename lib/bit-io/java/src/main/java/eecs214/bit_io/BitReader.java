package eecs214.bit_io;

import java.io.*;

/**
 * For writing a file one bit (or more) at a time.
 */
public final class BitReader implements Closeable {
  private InputStream inner;
  private byte bitBuf = 0;
  private byte nBits = 0;

  /**
   * Creates a {@code BitReader} to read from the given {@link InputStream}.
   * Once a {@code BitReader} has been created, the underlying {@code
   * InputStream} should no longer be used, or the resulting behavior is
   * undefined.
   *
   * @param adaptee the {@code InputStream} to read from
   */
  public BitReader(InputStream adaptee) {
    inner = adaptee;
  }

  /**
   * Creates a {@code BitReader} to read from the given {@link File}.
   *
   * @param file the file to open and read from
   * @throws FileNotFoundException if {@code file} does not exist or cannot
   * be opened
   */
  public BitReader(File file) throws FileNotFoundException {
    this(new FileInputStream(file));
  }

  /**
   * Creates a {@code BitReader} to read from the given file name.
   *
   * @param filename the name of the file to open and read from
   * @throws FileNotFoundException if {@code filename} does not exist or
   * cannot be opened
   */
  public BitReader(String filename) throws FileNotFoundException {
    this(new FileInputStream(filename));
  }

  @Override
  public void close() throws IOException {
    inner.close();
  }

  /**
   * Determines whether we've read to the end of the file.
   *
   * @return whether there are no remaining bits to read
   * @throws IOException on IO errors
   */
  public boolean isEof() throws IOException {
    refill();
    return nBits == 0;
  }

  /**
   * Reads the next bit from the input stream.
   *
   * @return {@code true} for 1, {@code false} for 0
   * @throws EOFException if there are no remaining bits to read
   * @throws IOException on IO errors
   */
  public boolean readBit() throws IOException {
    refill();
    if (nBits == 0) {
      throw new EOFException();
    }

    return (bitBuf >> --nBits & 1) == 1;
  }

  /**
   * Reads the next {@code n} bits from the input stream and returns them
   * interpreted as an {@code int}. For example, if the next eight bits in
   * the stream are 10010110, then {@code readBits(5)} reads the first five
   * bits, 10110, and returns them as the integer 22.
   * <p>
   * If there are fewer than {@code n} bits remaining to read,
   * this method consumes those bits and then throws an {@link EOFException}.
   *
   * @param n the number of bits to read
   * @return the number represented by the {@code n} bits
   * @throws EOFException if there are fewer than {@code n} bits remaining
   * @throws IOException on IO errors
   */
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
