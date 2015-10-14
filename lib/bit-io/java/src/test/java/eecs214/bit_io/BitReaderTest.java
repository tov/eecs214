package eecs214.bit_io;

import org.junit.Test;

import java.io.ByteArrayInputStream;
import java.io.EOFException;
import java.io.InputStream;

import static org.junit.Assert.*;

/**
 *
 */
public class BitReaderTest {
  @Test
  public void testNextBit() throws Exception {
    BitReader b = new BitReader(bytes(0x0F, 0x73));

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

  @Test
  public void testReadBits() throws Exception {
    BitReader b = new BitReader(bytes(0x0F, 0x73));

    assertEquals(b.readBits(4), 0);
    assertEquals(b.readBits(3), 7);
    assertEquals(b.readBits(4), 11);
    assertEquals(b.readBits(2), 2);
    assertEquals(b.readBits(3), 3);
  }


  @Test(expected = EOFException.class)
  public void testReadBits_exn() throws Exception {
    BitReader b = new BitReader(bytes(0x0F, 0x73));

    assertEquals(b.readBits(4), 0);
    assertEquals(b.readBits(3), 7);
    assertEquals(b.readBits(4), 11);
    assertEquals(b.readBits(2), 2);
    assertEquals(b.readBits(3), 3);
    assertEquals(b.readBits(3), 3);
  }

  @Test(expected = EOFException.class)
  public void testReadBits_exn_unaligned() throws Exception {
    BitReader b = new BitReader(bytes(0x0F, 0x73));

    assertEquals(b.readBits(4), 0);
    assertEquals(b.readBits(3), 7);
    assertEquals(b.readBits(4), 11);
    assertEquals(b.readBits(2), 2);
    assertEquals(b.readBits(2), 1);
    assertEquals(b.readBits(2), 2);
  }

  static InputStream bytes(int... ints) {
    byte[] bytes = new byte[ints.length];

    for (int i = 0; i < ints.length; ++i) {
      bytes[i] = (byte) ints[i];
    }

    return new ByteArrayInputStream(bytes);
  }
}
