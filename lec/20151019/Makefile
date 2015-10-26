DATE	= $(shell pwd | sed 's/.*\(........\)$$/\1/')
TARGET	= ../$(DATE).pdf

$(TARGET): slides.pdf
	cp $< $@

%.pdf: %.tex
	xelatex $<

hard: slides.tex
	xelatex $<
	xelatex $<
	xelatex $<
	make $(TARGET)
