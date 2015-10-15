/*
 * bit_io.h: facilities for reading and writing files one bit (or more)
 * at a time.
 *
 * The main idea is that we create a bit input or output stream as a
 * layer over a file open for reading or writing. The library maintains
 * a buffer of bits so that the client can view the file as a simple
 * sequence of bits rather than bytes.
 */

#ifndef BIT_IO_H_EECS214
#define BIT_IO_H_EECS214

#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>

/*
 * Abstract type of bit input streams
 */
typedef struct bit_in_t *bit_in;

/*
 * Abstract type of bit output streams
 */
typedef struct bit_out_t *bit_out;

/*
 * Creates a bit input stream that reads from the given open file
 * handle.
 *
 * The result of interleaving operations on the underlying file
 * handle with operations on the bit stream is unspecified.
 *
 * Parameters:
 *
 *      f - input file handle to read from
 *
 * Returns: a bit input stream handle, or NULL if memory cannot be
 * allocated
 *
 * Example:
 *
 *      bit_in bin = b_attach_in(fopen(input_file_name, "r"));
 *
 */
bit_in b_attach_in(FILE *f);

/*
 * Creates a bit output stream that writes to the given open file
 * handle.
 *
 * The result of interleaving operations on the underlying file
 * handle with operations on the bit stream is unspecified.
 *
 * Parameters:
 *
 *      f - output file handle to write to
 *
 * Returns: a bit output stream handle, or NULL if memory cannot be
 * allocated
 *
 * Example:
 *
 *      bit_out bout = b_attach_out(fopen(input_file_name, "w"));
 */
bit_out b_attach_out(FILE *f);

/*
 * Reads one bit from a bit input stream.
 *
 * Parameters:
 *
 *      bf - the bit input stream to read from
 *
 * Returns: 0, 1, or `EOF` on failure or end-of-file.
 *
 * Example:
 *
 *      int result = b_read_bit(bin);
 *      if (result == EOF) {
 *          // end-of-file
 *      } else {
 *          // result is the bit, 0 or 1
 *      }
 */
int b_read_bit(bit_in bf);

/*
 * Writes one bit to a bit output stream.
 *
 * Parameters:
 *
 *      bit - the bit to write
 *      bf - the bit output stream to write to
 *
 * Returns: 0 for success, or `EOF` on error or end-of-file.
 *
 * Example:
 *
 *      if (b_write_bit(true, bout) == EOF) {
 *          // write failed
 *      }
 */
int b_write_bit(bool bit, bit_out bf);

/*
 * Reads `nbits` bits from the bit input stream into the low-order
 * `nbits` bits of `bits`. Or in other words, reads `bits` as a
 * big-endian `nbits`-bit number.
 *
 * Parameters:
 *
 *      bits - pointer to store the result to
 *      nbits - number of bits to read
 *      bf - bit input stream to read from
 *
 * Returns: 0 for success, or `EOF` on failure or end-of-file.
 *
 * Example:
 *
 *      int result;
 *      if (b_read_bits(&result, 5, bin) == OEF) {
 *          // end-of-file or read error
 *      } else {
 *          // result contains the five-bit number that was read
 *      }
 */
int b_read_bits(int *bits, size_t nbits, bit_in bf);

/*
 * Writes the low-order `nbits` bits of `bits` to the bit output stream.
 * Or in other words, writes `bits` as a big-endian `nbits`-bit number.
 *
 * Parameters:
 *
 *      bits - number to write
 *      nbits - number of bits to write
 *      bf - bit output stream to write to
 *
 * Returns: 0 for success, or `EOF` on failure or end-of-file.
 *
 * Example:
 *
 *      if (b_write_bits(22, 5, bout) == OEF) {
 *          // end-of-file or read error
 *      } else {
 *          // wrote 10110 to stream
 *      }
 */
int b_write_bits(int bits, size_t nbits, bit_out bf);

/*
 * Determines whether there are no more bits to read. Note that because
 * files store bits in octets (bytes), the number of bits read will be a
 * multiple of 8, even if that exceeds the number explicitly written.
 *
 * Parameters:
 *
 *      bf - the bit input stream to check
 *
 * Returns: non-zero if there are no more bits to read, and zero if
 * there are
 *
 * Example:
 *
 *      while (! b_eof(bin)) {
 *          int b = b_read_bit(bin);
 *          ...
 *      }
 */
int b_eof(const bit_in bf);

/*
 * Disposes of a bit input stream, returning its resources to the system.
 *
 * Parameters:
 *
 *      bf - the bit input stream to close
 *
 * Example:
 *
 *      b_detach_in(bin);
 */
void b_detach_in(bit_in bf);

/*
 * Disposes of a bit output stream, padding with 0s the remaining bits to
 * the nearest full byte and returning its resources to the system.
 *
 * Parameters:
 *
 *      bf - the bit output stream to close
 *
 * Example:
 *
 *      b_detach_out(bout);
 */
void b_detach_out(bit_out bf);

#endif // BIT_IO_H_EECS214
