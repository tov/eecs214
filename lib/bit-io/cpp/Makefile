CXXFLAGS = -W -Wall -std=c++14
CXX      = c++ $(CXXFLAGS)

CLEAN  = encode decode *.o *.7 *.8

all: encode decode

encode: encode.o bit_io.o
	$(CXX) -o $@ $^

decode: decode.o bit_io.o
	$(CXX) -o $@ $^

encode.o: bit_io.hpp common.hpp
decode.o: bit_io.hpp common.hpp

clean:
	$(RM) $(CLEAN)

%.cpp.7: %.cpp encode
	./encode $< $@

%.8: %.7 decode
	./decode $< $@

test: encode.cpp.8
	diff encode.cpp encode.cpp.8

