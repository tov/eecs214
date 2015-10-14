#pragma once

#include <istream>
#include <ostream>
#include <fstream>

namespace eecs214 {
    /*
     * INPUT
     */

    class bifstream {
      public:
        explicit bifstream(const char* filespec);

        bifstream& read(bool&);

        template <class T>
        bifstream& read_bits(T& result, size_t n);

        bool eof() const;
        bool good() const;
        operator bool() const;

        bifstream(const bifstream&) = delete;

      private:
        char bitbuf;
        short nbits;
        std::ifstream stream;
    };

    template <class T>
    bifstream& bifstream::read_bits(T& result, size_t n)
    {
        bool bit;

        result = 0;

        while (n--) {
            read(bit);
            result = result << 1 | bit;
        }

        return *this;
    }

    inline bifstream& operator>>(bifstream& bif, bool& bit)
    {
        return bif.read(bit);
    }

    /*
     * OUTPUT
     */

    class bofstream {
      public:
        explicit bofstream(const char* filespec);

        bool good() const;
        operator bool() const;

        bofstream& write(bool);

        template <class T>
        bofstream& write_bits(T buf, size_t n);

        ~bofstream();

        bofstream(const bofstream&) = delete;

      private:
        char bitbuf;
        short nbits;
        std::ofstream stream;
        void write_out();
    };

    template <class T>
    bofstream& bofstream::write_bits(T buf, size_t n)
    {
        while (n--) {
            write(buf >> n & 1);
        }

        return *this;
    }

    inline bofstream& operator<<(bofstream& bof, bool bit)
    {
        return bof.write(bit);
    }
}
