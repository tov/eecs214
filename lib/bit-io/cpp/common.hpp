#pragma once

template <class Stream>
void assert_good(const Stream& stream, const char** argv)
{
    if (! stream.good()) {
        perror(argv[0]);
        exit(1);
    }
}

inline void usage(const char** argv)
{
    fprintf(stderr, "Usage: %s INFILE OUTFILE\n", argv[0]);
    exit(1);
}

