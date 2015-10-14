#include "bit_io.h"

#include <stdlib.h>
#include <string.h>

typedef struct {
    FILE *fp;
    int bitbuf;
    int nbits;
} bit_io_inner;

struct bit_in_t {
    bit_io_inner i;
};

struct bit_out_t {
    bit_io_inner i;
};

bit_io_inner *b_attach_inner(FILE *f)
{
    bit_io_inner *b = malloc(sizeof(*b));
    if (b == NULL) return NULL;

    b->nbits = b->bitbuf = 0;
    b->fp = f;
    return b;
}

bit_in b_attach_in(FILE *f)
{
    return (bit_in) b_attach_inner(f);
}

bit_out b_attach_out(FILE *f)
{
    return (bit_out) b_attach_inner(f);
}

static int b_write_out(bit_out bf)
{
    if (fputc(bf->i.bitbuf, bf->i.fp) == EOF) return EOF;
    bf->i.bitbuf = 0;
    bf->i.nbits = 0;
    return 0;
}

int b_write_bit(bool bit, bit_out bf)
{
    bf->i.bitbuf |= ((int) bit) << (7 - bf->i.nbits);
    if (++bf->i.nbits == 8)
        return b_write_out(bf);
    else
        return 0;
}

int b_read_bit(bit_in bf)
{
    if (bf->i.nbits == 0) {
        int c;

        if ((c = fgetc(bf->i.fp)) == EOF) return EOF;
        bf->i.bitbuf = c;
        bf->i.nbits = 8;
    }

    --bf->i.nbits;
    return (bf->i.bitbuf >> bf->i.nbits) & 1;
}

int b_write_bits(int bits, size_t size, bit_out bf)
{
    while (size--) {
        if (b_write_bit((bits >> size) & 1, bf) == EOF) return EOF;
    }

    return 0;
}

int b_read_bits(int *bits_p, size_t size, bit_in bf)
{
    int bits = 0;

    while (size--) {
        int result = b_read_bit(bf);
        if (result == EOF) return EOF;
        bits = (bits << 1) | result;
    }

    *bits_p = bits;

    return 0;
}

int b_eof(const bit_in bf)
{
    return bf->i.nbits == 0 && feof(bf->i.fp);
}

void b_detach_in(bit_in bf)
{
    free(bf);
}

void b_detach_out(bit_out bf)
{
    if (bf->i.nbits) b_write_out(bf);
    free(bf);
}
