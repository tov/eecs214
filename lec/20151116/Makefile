DATE	= $(shell pwd | sed 's/.*\(........\)$$/\1/')
TARGET	= ../$(DATE).pdf

LATEX	= xelatex

$(TARGET): combined.pdf
	cp $< $@

%.pdf: %.tex
	$(LATEX) $<

%.ps: %.pdf
	pdf2ps $<

%.pdf: %.ps
	ps2pdf $<

edited.ps: original.ps
	psselect -p 4-10,12-14,16,18-20,22,24-32,34,39 original.ps edited.ps

combined.ps: slides.ps edited.ps
	cat $^ > $@

hard: slides.tex
	$(LATEX) $<
	$(LATEX) $<
	$(LATEX) $<
	make $(TARGET)
