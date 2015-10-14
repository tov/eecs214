package eecs214.bit_io;

import org.junit.Test;

import java.io.ByteArrayOutputStream;
import java.io.IOException;

import static org.junit.Assert.assertEquals;

/**
 *
 */
public class BitWriterTest {
  ByteArrayOutputStream output = new ByteArrayOutputStream();
  BitWriter b = new BitWriter(output);

  @Test
  public void writeBitWritesBits() throws IOException {
    // 0x41
    b.writeBit(false);
    b.writeBit(true);
    b.writeBit(false);
    b.writeBit(false);
    assertEquals(output.toString(), "");
    b.writeBit(false);
    b.writeBit(false);
    b.writeBit(false);
    assertEquals(output.toString(), "");
    b.writeBit(true);
    assertEquals(output.toString(), "A");

    // 0x44
    b.writeBit(false);
    b.writeBit(true);
    b.writeBit(false);
    b.writeBit(false);
    b.writeBit(false);
    b.writeBit(true);
    b.writeBit(false);
    assertEquals(output.toString(), "A");
    b.writeBit(false);
    assertEquals(output.toString(), "AD");

    b.close();

    assertEquals(output.toString(), "AD");
  }

  @Test
  public void closeZeroPads() throws IOException {
    // 0x41
    b.writeBit(false);
    b.writeBit(true);
    b.writeBit(false);
    b.writeBit(false);
    assertEquals(output.toString(), "");
    b.writeBit(false);
    b.writeBit(false);
    b.writeBit(false);
    assertEquals(output.toString(), "");
    b.writeBit(true);
    assertEquals(output.toString(), "A");

    // 0x44
    b.writeBit(false);
    b.writeBit(true);
    b.writeBit(false);
    b.writeBit(false);
    b.writeBit(false);
    b.writeBit(true);
    // closing below will fill in the last two 0s
    assertEquals(output.toString(), "A");

    b.close();

    assertEquals(output.toString(), "AD");
  }

  @Test
  public void writeBitsWritesBits() throws IOException {
    // 0x41
    b.writeBits(0x41, 8);
    assertEquals("A", output.toString());

    // 0x44 = 0100 0100
    b.writeBits(4, 4);
    b.writeBits(4, 4);
    assertEquals("AD", output.toString());

    // 0x44 = 01 0001 00
    b.writeBits(1, 2);
    b.writeBits(1, 4);
    b.writeBits(0, 2);
    assertEquals("ADD", output.toString());

    b.close();
    assertEquals("ADD", output.toString());
  }
}
