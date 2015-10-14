#ifndef BIT_IO_H_EECS214
#define BIT_IO_H_EECS214

#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>

typedef uint8_t byte;
typedef struct bit_in_t *bit_in;
typedef struct bit_out_t *bit_out;

/*
 * Overlays a bit filter for reading from an open file handle. The
 * result of interleaving operations on the underlying file handle with
 * operations on the bit filter is unspecified.
 */
bit_in b_attach_in(FILE *f);

/*
 * Overlays a bit filter for writing to an open file handle. The result
 * of interleaving operations on the underlying file handle with
 * operations on the bit filter is unspecified.
 */
bit_out b_attach_out(FILE *f);

/*
 * Writes one bit to the bit filter. Returns the number of bytes written
 * to the bit filter's underlying file, or `EOF` on error or
 * end-of-file.
 */
int b_write_bit(bool bit, bit_out bf);

/*
 * Reads one bit from the bit filter. Returns 0 for false, 1 for true,
 * or `EOF` on failure or end-of-file.
 */
int b_read_bit(bit_in bf);

/*
 * Writes the low-order `nbits` bits of `bits` to the bit filter. Or in
 * other words, writes `bits` as a big-endian `nbits`-bit number.
 * Returns the number of bytes written to the bit filter's underlying
 * file, or `EOF` on error or end-of-file.
 */
int b_write_bits(int bits, size_t nbits, bit_out bf);

/*
 * Reads `nbits` bits from the bit filter into the low-order `nbits`
 * bits of `bits`. Or in other words, reads `bits` as a big-endian
 * `nbits`-bit number. Returns 0 for success or `EOF` on failure or
 * end-of-file.
 */
int b_read_bits(int *bits, size_t nbits, bit_in bf);

/*
 * Returns true if there are no more bits to read. Note that because
 * files store bits in octets (bytes), the number of bits read will be a
 * multiple of 8, even if that exceeds the number written.
 */
int b_eof(const bit_in bf);

/*
 * Disposes of a bit filter.
 */
void b_detach_in(bit_in bf);

/*
 * Disposes of a bit filter, padding with 0s the remaining bits to the
 * nearest full byte.
 */
void b_detach_out(bit_out bf);

#endif // BIT_IO_H_EECS214
