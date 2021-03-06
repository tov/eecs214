package eecs214.huffman;

import eecs214.bit_io.BitWriter;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * Sample program: encodes ASCII as a 7-bit block code, shrinking text files
 * by one-eight. Loses non-ASCII characters.
 */
public final class Encode {
  public static void main(String[] args) throws IOException {
    if (args.length != 2) usage();

    try (
      InputStream in = new FileInputStream(args[0]);
      BitWriter out = new BitWriter(args[1])
    ) {
      int c;

      while ((c = in.read()) != -1) {
        out.writeBits(c, 7);
      }
    }
  }

  private static void usage() {
    System.err.printf("Usage: java Encode.class INFILE OUTFILE%n");
    System.exit(2);
  }
}
