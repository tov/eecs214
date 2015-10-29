# The files to test the program on:
TESTFILES = bit_io.cpp

# Uncomment this next line to build on Cygwin/Windows:
# EXE_EXT = .exe

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

BUILD = $(HUFF) $(PUFF)
EX_BUILD = $(ENCODE) $(DECODE)
HUFF = huff$(EXE_EXT)
PUFF = puff$(EXE_EXT)
ENCODE = encode$(EXE_EXT)
DECODE = decode$(EXE_EXT)

CXXFLAGS = -W -Wall -std=c++11
LINK.o = $(CXX)

ENCODE_SRC = encode.cpp bit_io.cpp
ENCODE_INC = bit_io.hpp common.hpp

DECODE_SRC = decode.cpp bit_io.cpp
DECODE_INC = bit_io.hpp common.hpp

CLEAN       = *.o $(BUILD) $(EX_BUILD) $(TESTCLEAN)
TESTCLEAN   = *.7 *.8 *.huff *.puff .*.passed .*.ex_passed

all: $(BUILD)
example examples: $(EX_BUILD)

%$(EXE_EXT): %.o
	$(LINK.o) $^ $(LDFLAGS) $(LDLIBS) -o $@

$(HUFF): $(HUFF_SRC:.cpp=.o)
$(PUFF): $(PUFF_SRC:.cpp=.o)
$(ENCODE): $(ENCODE_SRC:.cpp=.o)
$(DECODE): $(DECODE_SRC:.cpp=.o)

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

%.7: % $(ENCODE)
	./$(ENCODE) $< $@

%.8: %.7 $(DECODE)
	./$(DECODE) $< $@

%.huff: % $(HUFF)
	./$(HUFF) $< $@

%.puff: %.huff $(PUFF)
	./$(PUFF) $< $@

testclean:
	$(RM) $(TESTCLEAN)

clean:
	$(RM) $(CLEAN)

.PRECIOUS: %.7 %.8 %.huff %.puff

.PHONY: all example examples test ex_test clean testclean
