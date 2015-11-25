DATE	= $(shell pwd | sed 's/.*\(........\)$$/\1/')
TARGET	= ../$(DATE).pdf

LATEX	= xelatex

$(TARGET): slides.pdf
	cp $< $@

%.pdf: %.tex
	$(LATEX) $<

hard: slides.tex
	$(LATEX) $<
	$(LATEX) $<
	$(LATEX) $<
	make $(TARGET)
