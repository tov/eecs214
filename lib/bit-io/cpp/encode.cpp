#include "bit_io.hpp"
#include "common.hpp"
#include <iostream>
#include <cstdio>

// These are the default files to read from and write to when no
// command-line arguments are given:
#define DEFAULT_INFILE  "hamlet.txt"
#define DEFAULT_OUTFILE "hamlet.txt.huff"

using namespace eecs214;
using namespace std;

void encode(istream& in, bofstream& out);

int main(int argc, const char *argv[])
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

    ifstream in(infile);
    assert_good(in, argv);

    bofstream out(outfile);
    assert_good(out, argv);

    encode(in, out);
}

void encode(istream& in, bofstream& out)
{
    char c;

    while (in.read(&c, 1)) {
        out.write_bits(c, 7);
    }
}
