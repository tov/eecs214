# A very short introduction to Make

If you aren’t very comfortable in the terminal then you should probably
build your C or C++ project using whatever IDE you are familiar with.
But if you want to try doing it terminal-style, and if you’re
comfortable enough with the shell to change directories to where your
project is, then you may want to try Make, the build tool that the
starter code comes configured for. Make is a build tool that uses rules
given in a file named `Makefile` (which must be in the current
directory) in order to accomplish various tasks.

## Building

To build your programs, run just `make`. If you haven't written `huff` and
`puff` yet, you should see something like this this:

```
$ make
make: *** No rule to make target `huff.cpp', needed by `huff.o'.  Stop.
$
```

(Don’t type the `$`—that’s just the shell prompt. Yours likely looks
different.)

Make knows that to build `huff`, it needs a file `huff.cpp` (or
`huff.c`—this document is written from the C++ perspective, but if
you’re using C then everything here applies once you adjust the names),
but it doesn’t know how where to get `huff.cpp` if you haven’t written
it yet. (Make is all about making things, so when there’s something that
it needs that isn’t there, it tries to make it.)

If you’re working on `huff.cpp` and haven’t started `puff.cpp` yet,
you’ll want a way to make one without the other. The command `make huff`
will try to make `huff`, and the command `make puff` will try to make
`puff`.

To build the example programs `encode` and `decode`, use `make example`:

```
$ make example
c++ -W -Wall -std=c++11   -c -o encode.o encode.cpp
c++ -W -Wall -std=c++11   -c -o bit_io.o bit_io.cpp
c++ encode.o bit_io.o   -o encode
c++ -W -Wall -std=c++11   -c -o decode.o decode.cpp
c++ decode.o bit_io.o   -o decode
$
```

Make prints out each command that it runs so that you can see what it’s
doing. And of course you can also make encode or make decode without the
other.

## Testing

Once you’ve written them, you can test your programs with `make test`.
By default, `make test` will compress and decompress the file
`bit_io.cpp` (or `bit_io.c`, if you’re using C), and then compare the
decompressed file to the original. To test more thoroughly than with
just one small file, you’ll have to edit the `Makefile`. The first two
lines of the file should initially look like this:

```
# The files to test the program on:
TESTFILES = bit_io.cpp
```

(If they don’t look like that then you should get a newer version from
Github.)

If you list more files on the second line then make test will try those
as well. For example, you could try `huff` on *Hamlet* and itself as well:

```
# The files to test the program on:
TESTFILES = bit_io.cpp hamlet.txt huff
```

(If `hamlet.txt` isn’t in the current directory then you’ll have to give
a path to it.)

You should try testing the example programs with `make ex_test`. Here’s
what it looks like when it passes:

```
$ make ex_test
./encode bit_io.cpp bit_io.cpp.7
./decode bit_io.cpp.7 bit_io.cpp.8
( diff bit_io.cpp bit_io.cpp.8 || cmp bit_io.cpp bit_io.cpp.8 ) && touch .bit_io.cpp.ex_passed
$
```

First, `encode` reads `bit_io.cpp` and writes a compressed version to
`bit_io.cpp.7`. (For `huff` the extension of the compressed file will be
`.huff` rather than `.7`.) Then `decode` reads the compressed file and
attempts to decompress it, writing the result to `bit_io.cpp.8`. (For
`puff` the extension will `.puff`.) The next line finds no differences
when comparing the original file `bit_io.cpp` with the decompressed
result `bit_io.cpp.8`.

And here’s what it looks like when it fails:

```
$ make ex_test
( diff bit_io.cpp bit_io.cpp.8 || cmp bit_io.cpp bit_io.cpp.8 ) && touch .bit_io.cpp.ex_passed
77a78
> HEY THIS SHOULDN'T BE HERE
cmp: EOF on bit_io.cpp
make: *** [.bit_io.cpp.ex_passed] Error 1
$
```

If both files are text files then `diff` prints out the difference, in
this case the addition of the line “`HEY THIS SHOULDN'T BE HERE`.” Then
`cmp` prints out the location of the first difference; in this case
“`EOF on bit_io.cpp`” means that the files were the same up until the
end of `bit_io.cpp`, but that `bit_io.cpp.8` didn’t end there.

## Configuring

The provided `Makefile` assumes that the only source file you wrote for
`huff` is `huff.cpp`, and that the only source file you write for `puff`
is `puff.cpp`. If you want to split your code into additional files, you
will have to edit the `Makefile`. There are four variables you may want
to change:

  - `HUFF_SRC`/PUFF_SRC`: List of C++ source files to be compiled into
    `huff`/`puff`

  - `HUFF_INC`/PUFF_INC`: List of C++ header that are included by
    `huff.cpp`/`puff.cpp` or one of its dependencies

Note that Make uses dependency information to decide which files need to
be rebuilt when other files change. If you include a header from a
new source file, you will have to tell Make about the dependency. See
the `Makefile` for how this is done for existing files—for example,
there is a line `huff.o: huff.c $(HUFF_INC)`, which means that `huff.o`
(the intermediate build product from compiling `huff.c`) depends on
`huff.c` and the list of includes as specified by `HUFF_INC`. You can
add analogous lines as necessary for other files you create.

