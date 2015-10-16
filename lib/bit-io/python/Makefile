test: bit_io.py bit_io.py.8
	diff $^

doc: bit_io.m.html

%.7: %
	./encode.py $< $@

%.8: %.7
	./decode.py $< $@

%.m.html: %.py
	$(RM) $@
	pdoc --html $<
