#!/usr/bin/env python

from sys import *
import bit_io

if len(argv) != 3:
    stderr.write('Usage: {} INFILE OUTFILE\n'.format(argv[0]))
    exit(2)

with open(argv[1], 'r') as input, bit_io.BitWriter(argv[2]) as output:
    while True:
        c = input.read(1)
        if not c: break
        output.writebits(ord(c), 7)
