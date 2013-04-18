#
# Useful version control stuff.
#

APP=colormake
CGIDIR=/home/httpd/cgi-bin

install:
	echo "Read the README, please!"

clean:
	find . -name "*~" -exec rm -f \{\} \;

release:	version clean
	echo cvs commit -m "Release ..."
	echo cvs tag -d `echo -n v;sed -e 's/\./_/g' <Dev.VERSION` 2>/dev/null >/dev/null
	echo cvs tag `echo -n v;sed -e 's/\./_/g' <Dev.VERSION`

dist:	release
	(cd ..;\
	 touch anomy/.exclude;\
 	 ls -1d anomy/.exclude anomy/CVS anomy/Makefile anomy/Dev.* anomy/*/CVS >anomy/.exclude;\
	 tar chvfz anomy-`cat anomy/Dev.VERSION`.tar.gz anomy/ -X anomy/.exclude )
