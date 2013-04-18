#!/bin/sh

bin=../bin/lpr-lin-prof
outprof=_out-prof1.txt

#optional run for 1 file
test -n "$2" &&
	if [ "$1" = "-img" ]
	then
		$bin "$2"
		mv gmon.out $(dirname $bin)
	fi

gprof -z -c $bin gmon*.out | tee $outprof |
	python gprof2dot.py | dot -Tpng -o $outprof.png &&
python gprof2dot.py -s -n 0 -e 0 $outprof | dot -Tpng -o $outprof.details.png

#options
echo
#echo -ne "Do you want to run kprof (will show results for 1 run) (y/N)? "
echo "Do you want to run kprof (will show results for 1 run) (y/N)? "
#read -n 1 ch
read ch
echo
test -n "$ch" &&
	if [ "$ch" = "y" ] || [ "$ch" = "Y" ]
	then
		kprof -f $bin -p gprof
	fi
echo

#echo -ne "Do you want html output (y/N)? "
echo "Do you want html output (y/N)? "
#read -n 1 ch
read ch
echo
test -n "$ch" &&
	if [ "$ch" = "y" ] || [ "$ch" = "Y" ]
	then
		python gprof2html.py $outprof
	fi
echo
