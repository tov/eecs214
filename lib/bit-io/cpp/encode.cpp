#include "bit_io.hpp"
#include "common.hpp"
#include <iostream>

using namespace eecs214;
using namespace std;

void encode(istream& in, bofstream& out);

int main(int argc, const char **argv)
{
    if (argc != 3) usage(argv);

    ifstream in(argv[1]);
    assert_good(in, argv);

    bofstream out(argv[2]);
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
