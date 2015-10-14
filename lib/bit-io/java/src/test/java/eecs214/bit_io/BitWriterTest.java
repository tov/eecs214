package eecs214.bit_io;

import org.junit.Test;

import java.io.ByteArrayOutputStream;
import java.io.IOException;

import static org.junit.Assert.assertEquals;

/**
 *
 */
public class BitWriterTest {
  @Test
  public void testWrite_boolean() throws IOException {
    ByteArrayOutputStream output = new ByteArrayOutputStream();
    BitWriter b = new BitWriter(output);

    b.writeBit(false);
    b.writeBit(true);
    b.writeBit(false);
    b.writeBit(false);
    b.writeBit(false);
    b.writeBit(false);
    b.writeBit(false);
    b.writeBit(true);

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
}
