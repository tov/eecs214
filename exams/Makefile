all: questions.pdf answers.pdf

%.pdf: %.tex
	pdflatex $<
	chmod a+r $@
