#!/bin/bash

source inc-test-begin.bash
source inc-test-outlog.bash


# prologue
runner=../bin/lpr-lin-debug
leaker=./leaker-lin

dbgfile=_all-debug.memlog
outfile=_out-debug.log
outfile2=_out-debug-verif.log

echo > $dbgfile
outlog_intro $outfile

while [ "$1" != "" ]
do
	# setup
	setup "$1"

	# run lpr + memory debug output
	for i in "${images[@]}"
	do
		test -f "$i" && $runner "$i" > "$i".memlog
	done

	# memory debug output check
	for i in "$directory/"*.memlog
	do
		$leaker "$i" >> $dbgfile
	done

	# lpr results
	outlog $outfile

	shift
done


# memory debug output results
echo -----
awk -f inc-test-debug-mem.awk $dbgfile
echo -----

# lpr results' verification
echo -----
awk -f inc-test-debug-verify.awk $outfile > $outfile2
cat $outfile2
echo -----
