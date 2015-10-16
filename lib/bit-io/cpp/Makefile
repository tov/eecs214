# The list of executables to build when typing just `make`:
BUILD = encode decode

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

CXXFLAGS = -W -Wall -std=c++14
CXX      = c++ $(CXXFLAGS)

CLEAN  = $(BUILD) *.o *.7 *.8

all: $(BUILD)

huff: $(HUFF_SRC:.cpp=.o)
	$(CXX) -o $@ $^

puff: $(HUFF_SRC:.cpp=.o)
	$(CXX) -o $@ $^

encode: encode.o bit_io.o
	$(CXX) -o $@ $^

decode: decode.o bit_io.o
	$(CXX) -o $@ $^

encode.o: bit_io.hpp common.hpp
decode.o: bit_io.hpp common.hpp
huff.o: bit_io.hpp
puff.o: bit_io.hpp

clean:
	$(RM) $(CLEAN)

%.cpp.7: %.cpp encode
	./encode $< $@

%.8: %.7 decode
	./decode $< $@

test: encode.cpp.8
	diff encode.cpp encode.cpp.8

