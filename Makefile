REMOTE = jesse@login.eecs.northwestern.edu:public_html/course/eecs214

default: css upload

upload:
	chmod -R a+rX .
	rsync -avz --exclude '.*' --progress . $(REMOTE)

css:
	make -C lib
