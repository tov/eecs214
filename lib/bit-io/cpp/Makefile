# The files to test the program on:
TESTFILES = bit_io.cpp

# C++ source and header files that `huff` depends on:
HUFF_SRC = huff.cpp bit_io.cpp
HUFF_INC = bit_io.hpp

# C++ source and header files that `puff` depends on:
PUFF_SRC = puff.cpp bit_io.cpp
PUFF_INC = bit_io.hpp

###
### You shouldn't need to modify anything below this line unless you
### are tinkering or trying to learn Make.
###

BUILD = huff puff
EX_BUILD = encode decode

CXXFLAGS = -W -Wall -std=c++11
LINK.o = $(CXX)

ENCODE_SRC = encode.cpp bit_io.cpp
ENCODE_INC = bit_io.hpp common.hpp

DECODE_SRC = decode.cpp bit_io.cpp
DECODE_INC = bit_io.hpp common.hpp

CLEAN       = $(BUILD) $(EX_BUILD) \
              *.o *.7 *.8 *.huff *.puff .*.passed .*.ex_passed

all: $(BUILD)
example examples: $(EX_BUILD)

huff: $(HUFF_SRC:.cpp=.o)
puff: $(PUFF_SRC:.cpp=.o)
encode: $(ENCODE_SRC:.cpp=.o)
decode: $(DECODE_SRC:.cpp=.o)

encode.o: encode.cpp $(ENCODE_INC)
decode.o: decode.cpp $(DECODE_INC)
huff.o: huff.cpp $(HUFF_INC)
puff.o: puff.cpp $(PUFF_INC)

test: $(TESTFILES:%=.%.passed)
ex_test: $(TESTFILES:%=.%.ex_passed)

.%.ex_passed: % %.8
	( diff $^ || cmp $^ ) && touch $@

.%.passed: % %.puff
	( diff $^ || cmp $^ ) && touch $@

%.7: % encode
	./encode $< $@

%.8: %.7 decode
	./decode $< $@

%.huff: % huff
	./huff $< $@

%.puff: %.huff puff
	./puff $< $@

clean:
	$(RM) $(CLEAN)

.PRECIOUS: %.7 %.8 %.huff %.puff
