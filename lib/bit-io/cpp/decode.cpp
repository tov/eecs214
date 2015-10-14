#include "bit_io.hpp"
#include "common.hpp"
#include <iostream>

using namespace eecs214;
using namespace std;

void decode(bifstream& in, ofstream& out);

int main(int argc, const char **argv)
{
    if (argc != 3) usage(argv);

    bifstream in(argv[1]);
    assert_good(in, argv);

    ofstream out(argv[2]);
    assert_good(out, argv);

    decode(in, out);
}

void decode(bifstream& in, ofstream& out)
{
    char c;

    while (in.read_bits(c, 7)) {
        out << c;
    }
}
