#include "bit_io.hpp"
#include <ios>

namespace eecs214 {
    using std::ios;

    bifstream::bifstream(const char* filespec)
        : bitbuf(0), nbits(0), stream(filespec, ios::binary)
    { }

    bool bifstream::good() const
    {
        return nbits > 0 || stream.good();
    }

    bifstream::operator bool() const
    {
        return good();
    }

    bool bifstream::eof() const
    {
        return nbits == 0 && stream.eof();
    }

    bifstream& bifstream::read(bool &bit)
    {
        if (nbits == 0) {
            if (! stream.read(&bitbuf, 1)) return *this;
            nbits = 8;
        }

        --nbits;
        bit = bitbuf >> nbits & 1;

        return *this;
    }

    bofstream::bofstream(const char* filespec)
        : bitbuf(0), nbits(0), stream(filespec, ios::binary|ios::trunc)
    { }

    bool bofstream::good() const
    {
        return stream.good();
    }

    bofstream::operator bool() const
    {
        return good();
    }

    void bofstream::write_out()
    {
        if (stream.write(&bitbuf, 1)) {
            bitbuf = 0;
            nbits = 0;
        }
    }

    bofstream& bofstream::write(bool bit)
    {
        bitbuf |= ((char) bit) << (7 - nbits);

        if (++nbits == 8) write_out();

        return *this;
    }

    bofstream::~bofstream()
    {
        if (nbits) {
            write_out();
        }
    }
}
