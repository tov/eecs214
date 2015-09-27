default:
	@$(MAKE) $(CSS)

CSS	= $(patsubst %.scss,%.css,$(wildcard *.scss))

%.css: %.scss
	sass $< $@
