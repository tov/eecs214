package eecs214.bit_io;

import java.io.*;

/**
 * For reading a file one bit (or more) at a time.
 */
public final class BitWriter implements Closeable {
  private OutputStream inner;
  private byte bitBuf = 0;
  private byte nBits = 0;

  /**
   * Creates a {@code BitWriter} to write to the given {@link OutputStream}.
   * Once a {@code BitWriter} has been created, the underlying {@code
   * OutputStream} should no longer be used, or the resulting behavior is
   * undefined.
   *
   * @param adaptee the {@code OutputStream} to write to
   */
  public BitWriter(OutputStream adaptee) {
    inner = adaptee;
  }

  /**
   * Creates a {@code BitWriter} to write to the given {@link File}.
   *
   * @param file the file to open and write to
   * @throws FileNotFoundException if {@code file} cannot be opened or created
   */
  public BitWriter(File file) throws FileNotFoundException {
    this(new FileOutputStream(file));
  }

  /**
   * Creates a {@code BitWriter} to write to the given {@link File}.
   *
   * @param filename the file to open and write to
   * @throws FileNotFoundException if {@code filename} cannot be opened
   * or created
   */
  public BitWriter(String filename) throws FileNotFoundException {
    this(new FileOutputStream(filename));
  }

  private void writeOut() throws IOException {
    inner.write(bitBuf);
    bitBuf = 0;
    nBits = 0;
  }

  /**
   * Writes a single bit to the output file.
   *
   * @param bit {@code true} for 1, {@code false} for 0
   * @throws IOException if an IO error occurs
   */
  public void writeBit(boolean bit) throws IOException {
    if (bit) {
      bitBuf |= 1 << (7 - nBits);
    }

    if (++nBits == 8) {
      writeOut();
    }
  }

  /**
   * Writes {@code value} to the file as an {@code n}-bit big-endian integer.
   * For example, {@code writeBits(22, 5)} writes the bits 10110 to the file.
   * This method does not check whether {@code n} bits is enough to represent
   * {@code value}, and instead writes the {@code n} low-order bits.
   *
   * @param value the number to write to the file
   * @param n the number of bits to use to represent {@code value}
   * @throws IOException if an IO error occurs
   */
  public void writeBits(long value, int n) throws IOException {
    while (n-- > 0) {
      writeBit((value & 1 << n) != 0);
    }
  }

  /**
   * Closes the file, flushing the buffer and zero-padding the last byte if
   * necessary.
   *
   * @throws IOException if an IO error occurs
   */
  @Override
  public void close() throws IOException {
    if (nBits > 0) {
      writeOut();
    }

    inner.close();
  }
}
