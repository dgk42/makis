#!/bin/bash

source inc-test-begin.bash
source inc-test-outlog.bash

# prologue
runner=../bin/lpr-lin
outfile=_out-release.log

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
