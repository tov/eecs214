package eecs214.huffman;

import eecs214.bit_io.BitReader;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

/**
 *
 */
public final class Decode {
  public static void main(String[] args) throws IOException {
    if (args.length != 2) usage();

    try (
      BitReader in = new BitReader(args[0]);
      OutputStream out = new FileOutputStream(args[1])
    ) {
      int c;

      while ((c = in.readBits(7)) != -1) {
        out.write(c);
      }
    }
  }

  private static void usage() {
    System.err.printf("Usage: java Encode.class INFILE OUTFILE");
    System.exit(2);
  }
}
