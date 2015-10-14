CFLAGS = -pedantic --std=c11 -W -Wall
CC     = cc $(CFLAGS)

CLEAN  = encode decode *.o *.7 *.8

all: encode decode

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

