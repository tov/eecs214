REMOTE = jesse@login.eecs.northwestern.edu:public_html/course/eecs214

default: css upload

upload:
	chmod -R a+rX .
	rsync -avz --progress --delete \
		--exclude '.*' \
		--exclude '*.class' \
		--exclude '*.o' \
		--exclude '*.pyc' \
		--exclude 'exams' \
		. $(REMOTE)

css:
	make -C lib
