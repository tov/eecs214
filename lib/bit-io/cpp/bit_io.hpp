#pragma once

/*
 * bit_io.hpp: classes for reading and writing files one bit (or more)
 * at a time.
 *
 * The main idea is that we create a bit input or output stream as a
 * layer over a file that we open for reading or writing. The library
 * maintains a buffer of bits so that the client can view the file as a
 * simple sequence of bits rather than bytes.
 */

#include <istream>
#include <ostream>
#include <fstream>

namespace eecs214 {
    /*
     * INPUT
     */

    // A bit input stream, for reading individual bits from a file.
    class bifstream {
      public:
        // Constructs a bit input stream to read from the given file.
        //
        // Parameters:
        //
        //      filespec - name of the file to open
        //
        // Example:
        //
        //      bifstream bif(input_file_name);
        //
        explicit bifstream(const char* filespec);

        // Reads a bit from this bit input stream into the given bool
        // reference.
        //
        // Parameters:
        //
        //      result - bool reference to store the bit that was read
        //
        // Returns: the same bit input stream, for method chaining
        //
        // Example:
        //
        //      bool b;
        //      bif.read(b);
        //
        bifstream& read(bool& result);

        // Reads `n` bits, interpreted as a big-endian `n`-bit integer,
        // and stores them in the reference `result`, which must have a
        // numeric type.
        //
        // Parameters:
        //
        //      <class T> - the type of the result; must be numeric
        //      result - reference for storing the result
        //      n - number of bits to read
        //
        // Returns: the same bit input stream, for method chaining
        //
        // Example:
        //
        //      int result;
        //      bif.read(result, 5); // reads 5 bits into result
        //
        template <class T>
        bifstream& read_bits(T& result, size_t n);

        // Determines whether we've reached the end of the input file.
        //
        // Returns: `true` if there are no more bits to read and `false`
        // if there are
        //
        // Example:
        //
        //      while (! bif.eof()) {
        //          bif.read(b);
        //          ...
        //      }
        //
        bool eof() const;

        // Determines the status of the bit input stream.
        //
        // Returns: `false` if there are no bits to read and a read
        // error has occurred, and `true` otherwise.
        //
        // Example:
        //
        //      bif.read(b);
        //      if (bif.good()) {
        //          // we know the read succeeded
        //      }
        //
        bool good() const;

        // The bit input stream boolean coercion operator, inserted, for
        // example, when a `bifstream` is used as a condition for an
        // `if`. Alias for `good()`.
        //
        // Returns: `false` if there are no bits to read and a read
        // error has occurred, and `true` otherwise.
        //
        // Example:
        //
        //      bif.read(b);
        //      if (bif) {
        //          // we know the read succeeded
        //      }
        //
        operator bool() const;

        bifstream(const bifstream&) = delete;

      private:
        char bitbuf;
        short nbits;
        std::ifstream stream;
    };

    // The bit input stream extraction operator; alias for `read(bool&)`.
    //
    // Params:
    //
    //     - bif - the bit input stream to read from
    //     - b - reference to store the bit that was read
    //
    // Returns: the same bit input stream, for method chaining
    //
    // Example:
    //
    //     bool b1, b2, b3;
    //     bif >> b1 >> b2 >> b3;
    //
    bifstream& operator>>(bifstream& bif, bool& b);

    /*
     * OUTPUT
     */

    // A bit output stream, for writing individual bits to a file.
    class bofstream {
      public:
        // Constructs a bit output stream to write to the given file.
        //
        // Parameters:
        //
        //      filespec - name of the file to open or create
        //
        // Example:
        //
        //      bofstream bof(output_file_name);
        //
        explicit bofstream(const char* filespec);

        // Writes a bit to this bit output stream.
        //
        // Parameters:
        //
        //      b - the bit to write
        //
        // Returns: the same bit output stream, for method chaining
        //
        // Example:
        //
        //      bof.write(true);
        //
        bofstream& write(bool b);

        // Writes an `n`-bit big-endian representation of `value`, which
        // must have a numeric type, to this bit output sream.
        //
        // Parameters:
        //
        //      <class T> - the type of the value to write; must be numeric
        //      value - the value to write
        //      n - number of bits to write
        //
        // Returns: the same bit output stream, for method chaining
        //
        // Example:
        //
        //      bof.write(22, 5); // writes 10110
        //      bof.write(22, 6); // writes 010110
        //
        template <class T>
        bofstream& write_bits(T value, size_t n);

        // Determines the status of the bit output stream.
        //
        // Returns: `false` if an error has occurred; `true` otherwise
        //
        // Example:
        //
        //      bof.write(b);
        //      if (bof.good()) {
        //          // we know the write succeeded
        //      }
        //
        bool good() const;

        // The bit output stream boolean coercion operator, inserted, for
        // example, when a `bofstream` is used as a condition for an
        // `if`. Alias for `good()`.
        //
        // Returns: `false` if an error has occurred; `true` otherwise
        //
        // Example:
        //
        //      bof.write(b);
        //      if (bof) {
        //          // we know the write succeeded
        //      }
        //
        operator bool() const;

        ~bofstream();

        bofstream(const bofstream&) = delete;

      private:
        char bitbuf;
        short nbits;
        std::ofstream stream;
        void write_out();
    };

    // The bit output stream insertion operator; alias for
    // `write(bool)`.
    //
    // Params:
    //
    //     - bof - the bit input stream to write to
    //     - b - the bit to write
    //
    // Returns: the same bit output stream, for method chaining
    //
    // Example:
    //
    //     bof << true << false << false;
    //
    bofstream& operator<<(bofstream& bof, bool b);

    /*
     * TEMPLATE IMPLEMENTATIONS
     */

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

    template <class T>
    bofstream& bofstream::write_bits(T value, size_t n)
    {
        while (n--) {
            write(value >> n & 1);
        }

        return *this;
    }

    inline bofstream& operator<<(bofstream& bof, bool bit)
    {
        return bof.write(bit);
    }
}
