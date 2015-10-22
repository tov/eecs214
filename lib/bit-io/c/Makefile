# The files to test the program on:
TESTFILES = bit_io.c

# The list of executables to build when typing just `make`:
BUILD = encode decode

# C++ source and header files that `huff` depends on:
HUFF_SRC = huff.c bit_io.c
HUFF_INC = bit_io.h

# C++ source and header files that `puff` depends on:
PUFF_SRC = puff.c bit_io.c
PUFF_INC = bit_io.h

###
### You shouldn't need to modify anything below this line unless you
### are tinkering or trying to learn Make.
###

CFLAGS      = -O2 -std=c99 -pedantic -W -Wall -Wextra

ENCODE_SRC  = encode.c bit_io.c
ENCODE_INC  = bit_io.h

DECODE_SRC  = decode.c bit_io.c
DECODE_INC  = bit_io.h

CLEAN       = $(BUILD) *.o *.7 *.8 *.huff *.puff .*.passed .*.ex_passed

all: $(BUILD)

huff: $(HUFF_SRC:.c=.o)
puff: $(PUFF_SRC:.c=.o)
encode: $(ENCODE_SRC:.c=.o)
decode: $(DECODE_SRC:.c=.o)

huff.o: huff.c $(HUFF_INC)
puff.o: puff.c $(PUFF_INC)
encode.o: encode.c $(ENCODE_INC)
decode.o: decode.c $(DECODE_INC)

%.huff: % huff
	./huff $< $@

%.puff: %.huff puff
	./puff $< $@

%.7: % encode
	./encode $< $@

%.8: %.7 decode
	./decode $< $@

test: $(TESTFILES:%=.%.passed)
ex_test: $(TESTFILES:%=.%.ex_passed)

.%.passed: % %.puff
	( diff $^ || cmp $^ ) && touch $@

.%.ex_passed: % %.8
	( diff $^ || cmp $^ ) && touch $@

clean:
	$(RM) $(CLEAN)
