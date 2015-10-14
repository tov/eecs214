package eecs214.bit_io;

import org.junit.Test;

import java.io.ByteArrayInputStream;
import java.io.EOFException;
import java.io.IOException;
import java.io.InputStream;

import static org.junit.Assert.*;

/**
 *
 */
public class BitReaderTest {
  BitReader b = new BitReader(bytes(0x0F, 0x73));

  @Test
  public void nextBitReadsBits() throws Exception {
    assertFalse(b.readBit());
    assertFalse(b.readBit());
    assertFalse(b.readBit());
    assertFalse(b.readBit());

    assertTrue(b.readBit());
    assertTrue(b.readBit());
    assertTrue(b.readBit());
    assertTrue(b.readBit());

    assertFalse(b.readBit());
    assertTrue(b.readBit());
    assertTrue(b.readBit());
    assertTrue(b.readBit());

    assertFalse(b.readBit());
    assertFalse(b.readBit());
    assertTrue(b.readBit());
    assertTrue(b.readBit());
  }

  @Test(expected = EOFException.class)
  public void nextBitThrowsOnEof() throws Exception {
    for (int i = 0; i < 17; ++i) {
      b.readBit();
    }
  }

  @Test
  public void isEofReturnsFalse() throws IOException {
    assertFalse(b.isEof());
    b.readBit(); // new
    assertFalse(b.isEof());
    b.readBits(6); // pre-aligned
    assertFalse(b.isEof());
    b.readBit(); // aligned
    assertFalse(b.isEof());
    b.readBit(); // post-aligned
    assertFalse(b.isEof());
    b.readBits(6); // pre-eof
  }

  @Test
  public void isEofReturnsTrue() throws IOException {
    b.readBits(16);
    assertTrue(b.isEof());
  }

  @Test
  public void readBitsReadsBits() throws Exception {
    assertEquals(b.readBits(4), 0);
    assertEquals(b.readBits(3), 7);
    assertEquals(b.readBits(4), 11);
    assertEquals(b.readBits(2), 2);
    assertEquals(b.readBits(3), 3);
  }

  @Test(expected = EOFException.class)
  public void readBitsThrowsAtEof() throws Exception {
    assertEquals(b.readBits(4), 0); // 4
    assertEquals(b.readBits(3), 7); // 7
    assertEquals(b.readBits(4), 11); // 11
    assertEquals(b.readBits(2), 2); // 13
    assertEquals(b.readBits(3), 3); // 16
    assertEquals(b.readBits(3), 3); // oops!
  }

  @Test(expected = EOFException.class)
  public void readBitsThrowsAcrossEof() throws Exception {
    assertEquals(b.readBits(4), 0); // 4
    assertEquals(b.readBits(3), 7); // 3
    assertEquals(b.readBits(4), 11); // 11
    assertEquals(b.readBits(2), 2); // 13
    assertEquals(b.readBits(2), 1); // 15
    assertEquals(b.readBits(2), 2); // oops!
  }

  static InputStream bytes(int... ints) {
    byte[] bytes = new byte[ints.length];

    for (int i = 0; i < ints.length; ++i) {
      bytes[i] = (byte) ints[i];
    }

    return new ByteArrayInputStream(bytes);
  }
}
