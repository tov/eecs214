#include "bit_io.h"
#include <stdio.h>

/* These are the default files to read from and write to when no
 * command-line arguments are given: */
#define DEFAULT_INFILE  "hamlet.txt.huff"
#define DEFAULT_OUTFILE "hamlet.txt.puff"

void decode(FILE* in, FILE* out);

int main(int argc, const char* argv[])
{
    const char *infile, *outfile;

    switch (argc) {
    // If there are two command-line arguments then they are the files
    // to read from and write to:
    case 3:
        infile = argv[1];
        outfile = argv[2];
        break;

    // If there are no command-line arguments then we use the default
    // input and output files:
    case 1:
        infile = DEFAULT_INFILE;
        outfile = DEFAULT_OUTFILE;
        break;

    // Any other number of arguments is a user error, so we print a help
    // message:
    default:
        fprintf(stderr, "Usage: %s [ INFILE OUTFILE ]\n", argv[0]);
        return 1;
    }

    FILE* in = fopen(infile, "r");
    if (!in) goto in_fail;

    FILE* out = fopen(outfile, "w");
    if (!out) goto out_fail;

    decode(in, out);

    fclose(out);
    fclose(in);

    return 0;

out_fail:
    fclose(in);

in_fail:
    perror(argv[0]);
    return 1;
}

void decode(FILE *in, FILE *out)
{
    int c;
    bit_in bf = b_attach_in(in);

    while (b_read_bits(&c, 7, bf) != EOF) {
        putc(c, out);
    }

    b_detach_in(bf);
}
