#!/bin/bash

source inc-test-begin.bash
source inc-test-outlog.bash

# prologue
runner=../bin/lpr-lin-prof
outfile=_out-profile.log
runnerdir=$(dirname $runner)

j=0
outlog_intro $outfile
while [ "$1" != "" ]
do
	# setup
	setup "$1"

	# run lpr
	for i in "${images[@]}"
	do
		if [ -f "$i" ]
		then
			$runner "$i"
			fname=$(basename "$i")
			if (( $j == 0 ))
			then
				first=gmon."$fname".out
			fi
			mv gmon.out gmon."$fname".out
			let j=$j+1
		fi
	done

	# lpr results
	outlog $outfile

	shift
done
cp "$first" $runnerdir/gmon.out

# NOTE: uncomment below lines for verification
# lpr results' verification
#echo -----
#awk -f inc-test-debug-verify.awk $outfile
#echo -----

#profiling output
sh do-profile.sh

rm $runnerdir/gmon.out
