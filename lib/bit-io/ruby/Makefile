test: bit_io.rb bit_io.rb.8
	diff $^

doc: bit_io.rb
	$(RM) -R $@
	rdoc $^

%.7: %
	./encode.rb $< $@

%.8: %.7
	./decode.rb $< $@
