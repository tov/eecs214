TESTFILES = bit_io.rb encode.rb

DIFFS = $(TESTFILES:=.diff)

test: $(DIFFS)

%.diff: % %.8
	diff $^ | tee $@

doc: bit_io.rb
	$(RM) -R $@
	rdoc $^

%.7: %
	./encode.rb $< $@

%.8: %.7
	./decode.rb $< $@

CLEAN = *.diff *.7 *.8

clean:
	$(RM) $(CLEAN)
