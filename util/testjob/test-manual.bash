#!/bin/bash

source inc-test-begin.bash
source inc-test-outlog.bash

echo "# entries in reference $reference"
while [ "$1" != "" ]
do
	# setup
	setup "$1"

	for i in "${images[@]}"
	do
		cw=$(basename "$i")
		cz=`grep ",$cw," $reference | wc -l`
		if [ "0" = "$cz" ]
		then
			cz=`grep ",\"$cw\"," $reference | wc -l`
		fi
		echo -ne $cz "\t\t" "$i\n" | awk '$1 !~ /^1/'
	done

	shift
done
