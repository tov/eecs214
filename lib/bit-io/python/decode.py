#!/usr/bin/env python

from sys import *
import bit_io

if len(argv) != 3:
    stderr.write('Usage: {} INFILE OUTFILE\n'.format(argv[0]))
    exit(2)

with bit_io.BitReader(argv[1]) as input, open(argv[2], 'w') as output:
    while True:
        c = input.readbits(7)
        if not c: break
        output.write(chr(c))

