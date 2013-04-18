#!/bin/bash

# example:
# %time bash testjob.bash testjob.rc test-debug.bash test-manual.bash


die ()
{
	echo "Usage: $0 RCFILE RUNNER[S]"
	echo "#RCFILE is a job descriptor file (e.g. testjob.rc)"
	echo "#RUNNER is a bash script (e.g test-release.bash)"
	exit 1
}

test -z "$2" && die

a=0
while read line
do
	test -z "$line" && continue
	c=`echo "$line" | grep ^#`
	test -n "$c" && continue
	if [ ! -d "$line" ]
	then
		echo ERROR: "$line" is not a directory
		continue
	fi
	b[a]=$line
	a=$(($a+1))
done < "$1"

while [ "$2" != "" ]
do
	d=0
	for i in "${b[@]}"
	do
		e=`ls -1 "$i" | wc -l`
		let d=$d+$e
	done
	# FIXME: i know it's a "bug" (counts all files, not just images)!!!
	echo $d files -- bash $2 "${b[@]}"
	bash $2 "${b[@]}"
	shift
done

#beep
echo -en "\007"
