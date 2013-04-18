#!/bin/bash

source inc-test-begin.bash
source inc-test-outlog.bash

# prologue
covdir=out-cov
srcdir=../src-dgk_1
objdir=obj-cov
runner=../bin/lpr-lin-cov
outfile=_out-coverage.log

outlog_intro $outfile

while [ "$1" != "" ]
do
	# setup
	setup "$1"

	# run lpr
	for i in "${images[@]}"
	do
		test -f "$i" && $runner "$i"
	done

	# lpr results
	outlog $outfile

	shift
done

# NOTE: uncomment below lines for verification
# lpr results' verification
#echo -----
#awk -f inc-test-debug-verify.awk $outfile
#echo -----

#coverage output
dir1=`pwd`
cd "$srcdir"

src=*.cpp
for i in $src
do
	gcov -b -o $objdir $i
done

cd "$dir1"

mv "$srcdir"/*.gcov $covdir
