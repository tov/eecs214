#pragma once

template <class Stream>
void assert_good(const Stream& stream, const char* argv[])
{
    if (! stream.good()) {
        perror(argv[0]);
        exit(1);
    }
}

// No longer used by decode/encode.cpp, but still may be used by student
// code.
inline void usage(const char* argv[])
{
    fprintf(stderr, "Usage: %s [ INFILE OUTFILE ]\n", argv[0]);
    exit(1);
}
