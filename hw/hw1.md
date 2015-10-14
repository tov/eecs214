# CS 214 Homework 1: Huffman Coding

Due 11:59 PM on Wednesday, October 28

## Introduction

For this homework, you will write two programs:

  - `encode` compresses text files using Huffman coding.

  - `decode` decompresses Huffman-coded files produced by encode, giving
    back the original file.

The filenames to read from and write to are passed to each program as
command-line arguments. For example, suppose you have a text file `hamlet.txt`
that you'd like to compress. You can compress it to a file `hamlet.txt.huff`
using your `encode` program:

```sh
    % ./encode hamlet.txt hamlet.txt.huff
```

You can decompress it using your `decode` program:

```sh
    % ./decode hamlet.txt.huff hamlet.txt.out
```

If you’ve done your job correctly, the decompressed file will match the
original. On UNIX (including Linux and Mac OS X) you can compare the two to
make sure they match using `diff`:

```sh
    % diff hamlet.txt hamlet.txt.out
```

When two files match `diff` prints nothing.

## Getting started

I've posted starter code, including bitwise IO libraries, for the five
languages we chose:

  - [C](https://github.com/tov/eecs214/tree/master/lib/bit-io/c)
  - [C++](https://github.com/tov/eecs214/tree/master/lib/bit-io/cpp)
  - [Python](https://github.com/tov/eecs214/tree/master/lib/bit-io/python)
  - [Ruby](https://github.com/tov/eecs214/tree/master/lib/bit-io/ruby)
  - [Java](https://github.com/tov/eecs214/tree/master/lib/bit-io/java)

The best way to get this code is to clone [the course Git
repository](https://github.com/tov/eecs214), which includes all five
languages in directory
[`lib/bit-io`](https://github.com/tov/eecs214/tree/master/lib/bit-io).
Or you can simply download the whole course repository as a [ZIP
file](https://github.com/tov/eecs214/archive/master.zip)

The starter code for each language includes versions of `encode` and
`decode` that, instead of Huffman coding, compress an ASCII text file to
7/8 of its original size. (ASCII uses only the low 7 bits in each byte
rather than all 8, so we can save each 8th bit by packing together only
the 7 significant bits. If a file includes non-ASCII characters then
they will be corrupted.)

