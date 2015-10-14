#include "bit_io.h"
#include <stdio.h>

void encode(FILE* in, FILE* out);
int usage(const char** argv);

int main(int argc, const char** argv)
{
    if (argc != 3) return usage(argv);

    FILE* in = fopen(argv[1], "r");
    if (!in) goto in_fail;

    FILE* out = fopen(argv[2], "w");
    if (!out) goto out_fail;

    encode(in, out);

    fclose(out);
    fclose(in);
    return 0;

out_fail:
    fclose(in);

in_fail:
    perror(argv[0]);
    return 1;
}

void encode(FILE *in, FILE *out)
{
    int c;
    bit_out bf = b_attach_out(out);

    while ((c = getc(in)) != EOF) {
        b_write_bits(c, 7, bf);
    }

    b_detach_out(bf);
}

int usage(const char** argv)
{
    fprintf(stderr, "Usage: %s INFILE OUTFILE\n", argv[0]);

    return 2;
}

