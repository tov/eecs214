# The list of executables to build when typing just `make`:
BUILD = encode decode

# C source and header files that `huff` depends on:
HUFF_SRC = huff.c bit_io.c
HUFF_INC = bit_io.h

# C source and header files that `puff` depends on:
PUFF_SRC = puff.c bit_io.c
PUFF_INC = bit_io.h

###
### You shouldn't need to modify anything below this line unless you
### are tinkering or trying to learn Make.
###

CFLAGS = -pedantic --std=c11 -W -Wall
CC     = cc $(CFLAGS)

CLEAN  = $(BUILD) *.o *.7 *.8

all: $(BUILD)

huff: $(HUFF_SRC:.c=.o)
	$(CC) -o $@ $^

puff: $(PUFF_SRC:.c=.o)
	$(CC) -o $@ $^

encode: encode.o bit_io.o
	$(CC) -o $@ $^

decode: decode.o bit_io.o
	$(CC) -o $@ $^

encode.o: bit_io.h
decode.o: bit_io.h

clean:
	$(RM) $(CLEAN)

%.c.7: %.c encode
	./encode $< $@

%.8: %.7 decode
	./decode $< $@

test: encode.c.8
	diff encode.c encode.c.8

