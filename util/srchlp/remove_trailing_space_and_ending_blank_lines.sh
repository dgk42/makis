#!/bin/sh

die ()
{
	echo "Usage: $0 FILE1 [FILE2 ... FILEN]" 1>&2
	exit 0
}

test -z "$1" && die

awkf="`dirname "$0"`/remove_ending_blank_lines.awk"
for i in "$@"
do
	if [ -f "$i" ]
	then
		echo "$i"
		sed 's/[[:blank:]]*$//' "$i"| \
			awk -f "$awkf" > "$i.tmp" && \
			mv "$i.tmp" "$i"
	fi
done
