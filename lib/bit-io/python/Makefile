TESTFILES = bit_io.py encode.py

DIFFS = $(TESTFILES:=.diff)

test: $(DIFFS)

%.diff: % %.8
	diff $^ | tee $@

doc: bit_io.m.html

%.7: %
	./encode.py $< $@

%.8: %.7
	./decode.py $< $@

%.m.html: %.py
	$(RM) $@
	pdoc --html $<

CLEAN = *.diff *.7 *.8 *.pyc

clean:
	$(RM) $(CLEAN)
